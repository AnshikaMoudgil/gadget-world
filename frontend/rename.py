import os

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return # Skip non-text files

    new_content = content.replace('gadget_world', 'gadget_world')
    new_content = new_content.replace('Gadget World', 'Gadget World')
    new_content = new_content.replace('gadget world', 'gadget world')
    new_content = new_content.replace('GadgetWorld', 'GadgetWorld')
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

def main():
    skip_dirs = {'.git', '.dart_tool', 'build', '.idea', '.vscode'}
    
    for root, dirs, files in os.walk('d:\\gadget-world\\frontend'):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for file in files:
            filepath = os.path.join(root, file)
            replace_in_file(filepath)

if __name__ == '__main__':
    main()
