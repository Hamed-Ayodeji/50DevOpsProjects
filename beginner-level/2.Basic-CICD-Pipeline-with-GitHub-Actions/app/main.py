def greet(name: str) -> str:
  """
  Returns a greeting message for the given name.
  """
  if not isinstance(name, str):
    return "Hello, Stranger!"
  if not name.strip():
    return "Hello, Stranger!"
  return f"Hello, {name.strip().capitalize()}!"

if __name__ == "__main__":
  try:
    name = input("Enter your name: ")
    print(greet(name))
  except Exception as e:
    print(f"An error occurred: {e}")