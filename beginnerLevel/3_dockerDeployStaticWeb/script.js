document.addEventListener("DOMContentLoaded", function () {
  // Load Gallery Images
  const images = document.querySelectorAll("#gallery .image img");
  images.forEach((img, index) => {
    img.src = `https://picsum.photos/300/300?random=${Date.now() + index}`;
    img.onerror = () => (img.src = "https://via.placeholder.com/300"); // Fallback
    img.onload = () => {
      img.previousElementSibling.style.display = "none"; // Hide spinner
    };
  });

  // Hamburger Menu Toggle for Mobile
  const mobileMenu = document.getElementById("mobile-menu");
  const navMenu = document.querySelector(".nav-menu");
  mobileMenu.addEventListener("click", function () {
    navMenu.classList.toggle("active");
  });

  // Scroll Top Button Functionality
  const scrollTopBtn = document.getElementById("scrollTopBtn");
  window.addEventListener("scroll", function () {
    if (window.scrollY > 300) {
      scrollTopBtn.style.display = "flex";
    } else {
      scrollTopBtn.style.display = "none";
    }
  });

  scrollTopBtn.addEventListener("click", function () {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });

  // Smooth Scroll for the Scroll-Down Icon with Offset
  const scrollDownLink = document.querySelector(".scroll-down");
  if (scrollDownLink) {
    scrollDownLink.addEventListener("click", function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute("href"));
      // Calculate offset to account for the fixed navbar height
      const navHeight = document.querySelector(".navbar").offsetHeight;
      const targetPosition =
        target.getBoundingClientRect().top + window.pageYOffset - navHeight;
      window.scrollTo({
        top: targetPosition,
        behavior: "smooth",
      });
    });
  }

  // Update Active Nav Link on Scroll
  const sections = document.querySelectorAll("header, section, footer");
  const navLinks = document.querySelectorAll(".nav-link");

  window.addEventListener("scroll", function () {
    let currentSection = "";
    sections.forEach((section) => {
      const sectionTop = section.offsetTop - 70; // Adjust if needed
      if (pageYOffset >= sectionTop) {
        currentSection = section.getAttribute("id");
      }
    });
    navLinks.forEach((link) => {
      link.classList.remove("active");
      if (link.getAttribute("href").includes(currentSection)) {
        link.classList.add("active");
      }
    });
  });
});
