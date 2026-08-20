#!/usr/bin/env python3
import re
import sys
import pathlib
import subprocess
from html.parser import HTMLParser


class HTMLToMarkdown(HTMLParser):
    """Convert HTML to Markdown, preserving formatting like bold, lists, headings, etc."""
    
    def __init__(self):
        super().__init__()
        self.markdown = []
        self.list_stack = []  # Track nested lists
        self.in_pre = False
        self.in_code = False
        self.code_buffer = []
        self.current_link = None
        self.skip_data = False
        
    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        
        if tag == 'strong' or tag == 'b':
            self.markdown.append('**')
        elif tag == 'em' or tag == 'i':
            self.markdown.append('*')
        elif tag == 'code':
            if not self.in_pre:
                self.markdown.append('`')
                self.in_code = True
        elif tag == 'pre':
            self.in_pre = True
            self.code_buffer = []
        elif tag == 'ul' or tag == 'ol':
            self.list_stack.append(tag)
            if len(self.list_stack) > 1:
                self.markdown.append('\n')
        elif tag == 'li':
            indent = '  ' * (len(self.list_stack) - 1)
            if self.list_stack and self.list_stack[-1] == 'ol':
                self.markdown.append(f'{indent}1. ')
            else:
                self.markdown.append(f'{indent}- ')
        elif tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            level = int(tag[1])
            self.markdown.append('#' * level + ' ')
        elif tag == 'a':
            self.current_link = attrs_dict.get('href', '')
        elif tag == 'br':
            self.markdown.append('\n')
        elif tag == 'p':
            if self.markdown and self.markdown[-1] != '\n':
                self.markdown.append('\n\n')
        elif tag == 'hr':
            self.markdown.append('\n---\n')
            
    def handle_endtag(self, tag):
        if tag == 'strong' or tag == 'b':
            self.markdown.append('**')
        elif tag == 'em' or tag == 'i':
            self.markdown.append('*')
        elif tag == 'code':
            if not self.in_pre:
                self.markdown.append('`')
                self.in_code = False
        elif tag == 'pre':
            self.in_pre = False
            code = ''.join(self.code_buffer).strip()
            self.markdown.append(f'\n```\n{code}\n```\n')
            self.code_buffer = []
        elif tag == 'ul' or tag == 'ol':
            if self.list_stack:
                self.list_stack.pop()
            if len(self.list_stack) == 0:
                self.markdown.append('\n')
        elif tag == 'li':
            # Add newline to separate list items
            if self.markdown and self.markdown[-1] != '\n':
                self.markdown.append('\n')
        elif tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
            self.markdown.append('\n\n')
        elif tag == 'a':
            if self.current_link:
                self.markdown.append(f']({self.current_link})')
                self.current_link = None
        elif tag == 'p':
            if self.markdown and self.markdown[-1] != '\n':
                self.markdown.append('\n')
                
    def handle_data(self, data):
        if self.in_pre:
            self.code_buffer.append(data)
        elif self.current_link and '[' not in ''.join(self.markdown[-3:]):
            self.markdown.append(f'[{data}')
        else:
            self.markdown.append(data)
            
    def get_markdown(self):
        return ''.join(self.markdown)


def get_html_from_clipboard():
    """Try to get HTML content from macOS clipboard."""
    try:
        result = subprocess.run(
            ['osascript', '-e', 'the clipboard as «class HTML»'],
            capture_output=True,
            text=True,
            check=True
        )
        # Convert hex string to actual HTML
        hex_data = result.stdout.strip()
        if hex_data.startswith('«data HTML') and hex_data.endswith('»'):
            hex_str = hex_data[10:-1]  # Remove «data HTML and »
            try:
                html_bytes = bytes.fromhex(hex_str)
                return html_bytes.decode('utf-8', errors='ignore')
            except Exception:
                return None
        return None
    except Exception:
        return None


def html_to_markdown(html: str) -> str:
    """Convert HTML to Markdown."""
    parser = HTMLToMarkdown()
    parser.feed(html)
    return parser.get_markdown()


def normalize(md: str) -> str:
    # Normalize line endings
    md = md.replace('\r\n', '\n').replace('\r', '\n')

    # Smart quotes → straight
    md = (md.replace('"', '"').replace('"', '"')
            .replace(''', "'").replace(''', "'"))
    
    # Replace en dash with regular hyphen
    md = md.replace('–', '-')

    # Remove gremlin characters like U+FFFC (object replacement character)
    md = re.sub(r'[\ufffc\ufffe\ufeff]', '', md)

    # Remove trailing whitespace from each line
    md = re.sub(r'[ \t]+$', '', md, flags=re.M)

    # Collapse multiple blank lines into at most 2
    md = re.sub(r'\n{3,}', '\n\n', md)

    # Fix malformed list items: "- \n**text**" or "-\n**text**" -> "- **text**"
    # This handles cases where list bullet and content are on separate lines
    md = re.sub(r'^([ \t]*)([-+*])[ \t]*\n+(?![ \t]*[-+*])', r'\1\2 ', md, flags=re.M)

    # Replace bullets (*, •) with "-" while preserving indentation
    # But preserve ** for bold text
    # Capture leading whitespace (tabs and spaces), replace tabs with 2 spaces
    def replace_bullet(m):
        indent = m.group(1).replace('\t', '  ')
        return indent + '- '
    # Match * or • at start of line (not ** for bold)
    md = re.sub(r'^([ \t]*)([*•])[ \t]+', replace_bullet, md, flags=re.M)

    # Normalize nested list indentation: multiples of two spaces
    def fix_indent(m):
        lead = m.group(1)
        bullet = m.group(2)
        text = m.group(3)
        # count spaces, snap to nearest multiple of 2
        n = len(lead.replace('\t', '  '))
        n = max(0, 2 * round(n / 2))
        return (' ' * n) + bullet + ' ' + text
    md = re.sub(r'^( *)([-+]) +(.+)$', fix_indent, md, flags=re.M)  # keep "-" or "+"

    # Ensure blank lines before/after fenced code & lists
    def ensure_blank_around(block_pattern, s):
        def add_blank_before(m):
            start = m.start()
            if start > 0 and s[m.start()-1] != '\n':
                return '\n' + m.group(0)
            if start >= 2 and s[m.start()-2:m.start()] != '\n\n':
                return '\n' + m.group(0)
            return m.group(0)
        s = re.sub(block_pattern, add_blank_before, s)
        # After: ensure one blank line
        s = re.sub(block_pattern + r'(?!\n\n)', lambda m: m.group(0) + '\n', s)
        return s

    code_fence_pat = r'```[\s\S]*?```'
    list_block_pat = r'(?:^(?: {0,6}[-+]\s.+)(?:\n(?: {2,}[-+]\s.+| {2,}.+|[-+]\s.+))*)'

    md = ensure_blank_around(code_fence_pat, md)
    md = ensure_blank_around(list_block_pat, md)

    # Trim trailing spaces
    md = re.sub(r'[ \t]+$', '', md, flags=re.M)

    # Normalize heading spacing: "# Title" (single space)
    md = re.sub(r'^(#{1,6})[ \t]*', r'\1 ', md, flags=re.M)

    # Final cleanup: collapse excess blank lines again and remove trailing whitespace
    md = re.sub(r'\n{3,}', '\n\n', md)
    md = re.sub(r'[ \t]+$', '', md, flags=re.M)
    
    # Trim leading/trailing whitespace from entire document
    md = md.strip()

    return md

def main():
    # Check for --clipboard or -c flag
    use_clipboard = False
    args = sys.argv[1:]
    
    if args and args[0] in ['--clipboard', '-c']:
        use_clipboard = True
        args = args[1:]  # Remove the flag from args
    
    if use_clipboard:
        # Try to get HTML from clipboard first
        html = get_html_from_clipboard()
        if html:
            inp = html_to_markdown(html)
        else:
            # Fall back to plain text from clipboard
            try:
                result = subprocess.run(['pbpaste'], capture_output=True, text=True, check=True)
                inp = result.stdout
            except Exception:
                print("Error: Could not read from clipboard", file=sys.stderr)
                sys.exit(1)
    elif len(args) < 1:
        # Read from stdin if no arguments
        inp = sys.stdin.read()
        # Try to detect if it's HTML and convert it
        if '<' in inp and ('</p>' in inp or '</div>' in inp or '<strong>' in inp or '<ul>' in inp):
            inp = html_to_markdown(inp)
    elif args[0] == '-' or args[0] == '/dev/stdin':
        # Explicit stdin
        inp = sys.stdin.read()
        # Try to detect if it's HTML and convert it
        if '<' in inp and ('</p>' in inp or '</div>' in inp or '<strong>' in inp or '<ul>' in inp):
            inp = html_to_markdown(inp)
    else:
        # Read from file
        inp = pathlib.Path(args[0]).read_text(encoding='utf-8')

    out = normalize(inp)

    if len(args) > 1:
        pathlib.Path(args[1]).write_text(out, encoding='utf-8')
    elif use_clipboard:
        # Copy result back to clipboard
        try:
            subprocess.run(['pbcopy'], input=out, text=True, check=True)
            print("✓ Processed and copied to clipboard", file=sys.stderr)
        except Exception:
            print(out)
    else:
        sys.stdout.write(out)

if __name__ == "__main__":
    main()

