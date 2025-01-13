# **App Documentation**

## **Overview**

This simple Python app prompts the user for their name and generates a personalized greeting based on the input. It is designed to be user-friendly, interactive, and robust.

---

## **Functionality**

### 1. **Personalized Greeting (`greet` Function)**  

- The `greet` function accepts a single argument, `name` (a string), and returns a greeting in the format:  
     **`Hello, {name}!`**  
- **Key Features**:
  - Strips leading and trailing whitespace from the input.
  - Capitalizes the first letter of the name to ensure a professional format.
  - Defaults to **"Hello, Stranger!"** if the input is empty or contains only whitespace.

### 2. **Interactive Execution**  

- The script uses a conditional block to execute only when run directly (not imported as a module):  

     ```python
     if __name__ == "__main__":
     ```

- When executed:
  - Prompts the user for their name:
       **`input("Enter your name: ")`**.
  - Calls the `greet` function with the input.
  - Displays the resulting greeting in the console.

### 3. **Validation and Error Handling**  

- Handles user input gracefully by:
  - Removing unnecessary whitespace.
  - Responding with a default message for empty input.
- Uses a `try-except` block to catch and log unexpected errors:  

     ```python
     except Exception as e:
         print(f"An error occurred: {e}")
     ```

### 4. **Default Behavior for Invalid Input**  

- Invalid inputs (e.g., empty strings or spaces) result in a default greeting:  
     **"Hello, Stranger!"**

---

## **Example Interaction**

```plaintext
$ python greet.py
Enter your name: Alice
Hello, Alice!

$ python greet.py
Enter your name:  
Hello, Stranger!

$ python greet.py
Enter your name: bob
Hello, Bob!
```

---

## **Setup**

### 1. **Installation**  

- No additional libraries or dependencies are required.

### 2. **Usage**  

- Run the script using:

     ```bash
     python app/main.py
     ```

---
