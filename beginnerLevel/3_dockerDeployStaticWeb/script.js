document.addEventListener("DOMContentLoaded", function () {
  const images = document.querySelectorAll("#gallery .image img");
  images.forEach((img, index) => {
    img.src = `https://picsum.photos/300/300?random=${Date.now() + index}`;
    img.onerror = () => (img.src = "https://via.placeholder.com/300"); // Fallback
    img.onload = () => {
      img.previousElementSibling.style.display = "none"; // Hide spinner
    };
  });
});
