import unittest
from app.main import greet

class TestGreetFunction(unittest.TestCase):
    def test_valid_inputs(self):
        """Test greet with valid string inputs."""
        self.assertEqual(greet("World"), "Hello, World!")
        self.assertEqual(greet("alice"), "Hello, Alice!")
        self.assertEqual(greet("  bob  "), "Hello, Bob!")
        self.assertEqual(greet("CHARLIE"), "Hello, Charlie!")

    def test_empty_and_whitespace_inputs(self):
        """Test greet with empty or whitespace-only inputs."""
        self.assertEqual(greet(""), "Hello, Stranger!")
        self.assertEqual(greet("   "), "Hello, Stranger!")

    def test_non_string_inputs(self):
        """Test greet with non-string inputs to ensure robustness."""
        self.assertEqual(greet(123), "Hello, Stranger!")
        self.assertEqual(greet(None), "Hello, Stranger!")
        self.assertEqual(greet([]), "Hello, Stranger!")
        self.assertEqual(greet({}), "Hello, Stranger!")

    def test_strip_and_capitalize_behavior(self):
        """Test that the function correctly strips and capitalizes inputs."""
        self.assertEqual(greet("  eve"), "Hello, Eve!")
        self.assertEqual(greet("dANIEL"), "Hello, Daniel!")
        self.assertEqual(greet("  mARY  "), "Hello, Mary!")

    def test_special_character_inputs(self):
        """Test greet with names containing special characters."""
        self.assertEqual(greet("o'neill"), "Hello, O'neill!")
        self.assertEqual(greet("anne-marie"), "Hello, Anne-marie!")

    def test_numeric_string_inputs(self):
        """Test greet with numeric strings."""
        self.assertEqual(greet("12345"), "Hello, 12345!")

if __name__ == "__main__":
    unittest.main()
