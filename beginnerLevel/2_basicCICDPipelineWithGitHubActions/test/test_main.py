import unittest
from app.main import greet

class TestGreetFunction(unittest.TestCase):
    def test_valid_inputs(self):
        """Test greet with valid string inputs."""
        self.assertEqual(greet("World"), "Hi, World!")
        self.assertEqual(greet("alice"), "Hi, Alice!")
        self.assertEqual(greet("  bob  "), "Hi, Bob!")
        self.assertEqual(greet("CHARLIE"), "Hi, Charlie!")

    def test_empty_and_whitespace_inputs(self):
        """Test greet with empty or whitespace-only inputs."""
        self.assertEqual(greet(""), "Hi, Stranger!")
        self.assertEqual(greet("   "), "Hi, Stranger!")

    def test_non_string_inputs(self):
        """Test greet with non-string inputs to ensure robustness."""
        self.assertEqual(greet(123), "Hi, Stranger!")
        self.assertEqual(greet(None), "Hi, Stranger!")
        self.assertEqual(greet([]), "Hi, Stranger!")
        self.assertEqual(greet({}), "Hi, Stranger!")

    def test_strip_and_capitalize_behavior(self):
        """Test that the function correctly strips and capitalizes inputs."""
        self.assertEqual(greet("  eve"), "Hi, Eve!")
        self.assertEqual(greet("dANIEL"), "Hi, Daniel!")
        self.assertEqual(greet("  mARY  "), "Hi, Mary!")

    def test_special_character_inputs(self):
        """Test greet with names containing special characters."""
        self.assertEqual(greet("o'neill"), "Hi, O'neill!")
        self.assertEqual(greet("anne-marie"), "Hi, Anne-marie!")

    def test_numeric_string_inputs(self):
        """Test greet with numeric strings."""
        self.assertEqual(greet("12345"), "Hi, 12345!")

if __name__ == "__main__":
    unittest.main()
