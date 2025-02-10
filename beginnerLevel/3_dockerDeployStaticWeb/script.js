document.addEventListener("DOMContentLoaded", () => {
  // Load Gallery Images
  const images = document.querySelectorAll("#gallery .image img");
  images.forEach((img, index) => {
    const imageUrl = `https://picsum.photos/300/300?random=${Date.now() + index}`;
    img.crossOrigin = "anonymous"; // Enable cross-origin download if permitted
    img.src = imageUrl;
    img.onerror = () => {
      img.src = "https://via.placeholder.com/300";
    };
    img.onload = () => {
      // Hide the spinner after the image loads
      const spinner = img.previousElementSibling;
      if (spinner) spinner.style.display = "none";
    };
  });

  // Hamburger Menu Toggle for Mobile
  const mobileMenu = document.getElementById("mobile-menu");
  const navMenu = document.querySelector(".nav-menu");
  mobileMenu.addEventListener("click", () => {
    navMenu.classList.toggle("active");
  });

  // Scroll Top Button Functionality
  const scrollTopBtn = document.getElementById("scrollTopBtn");
  window.addEventListener("scroll", () => {
    scrollTopBtn.style.display = window.scrollY > 300 ? "flex" : "none";
  });
  scrollTopBtn.addEventListener("click", () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });

  // Smooth Scroll for the Scroll Down Icon with Offset
  const scrollDownLink = document.querySelector(".scroll-down");
  if (scrollDownLink) {
    scrollDownLink.addEventListener("click", (e) => {
      e.preventDefault();
      const targetId = scrollDownLink.getAttribute("href");
      const target = document.querySelector(targetId);
      if (target) {
        const navHeight = document.querySelector(".navbar").offsetHeight;
        const targetPosition =
          target.getBoundingClientRect().top + window.pageYOffset - navHeight;
        window.scrollTo({ top: targetPosition, behavior: "smooth" });
      }
    });
  }

  // Modal Functionality for Viewing and Downloading Images
  const modal = document.getElementById("modal");
  const modalImg = document.getElementById("modal-img");
  const downloadLink = document.getElementById("download-link");
  const modalClose = document.querySelector(".modal-close");

  // Open modal when any gallery image is clicked
  images.forEach((img) => {
    img.addEventListener("click", () => {
      modal.style.display = "block";
      modalImg.src = img.src;
      downloadLink.href = img.src;
      downloadLink.setAttribute("download", "image-" + Date.now() + ".jpg");
    });
  });

  // Close modal when clicking the close button
  modalClose.addEventListener("click", () => {
    modal.style.display = "none";
  });

  // Close modal when clicking outside the modal content
  window.addEventListener("click", (event) => {
    if (event.target === modal) {
      modal.style.display = "none";
    }
  });

  // Close modal when pressing the Escape key
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && modal.style.display === "block") {
      modal.style.display = "none";
    }
  });

  // Update Active Navigation Link on Scroll
  const sections = document.querySelectorAll("header, section, footer");
  const navLinks = document.querySelectorAll(".nav-link");
  window.addEventListener("scroll", () => {
    let currentSection = "";
    sections.forEach((section) => {
      const sectionTop = section.offsetTop - 70; // Adjust offset if needed
      if (window.pageYOffset >= sectionTop) {
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
