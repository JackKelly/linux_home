def set_path():
    import sys
    old_path = sys.path
    sys.path = [path for path in sys.path if path]
    if len(sys.path) < len(old_path):
        print("Removed '' from path!")


set_path()
