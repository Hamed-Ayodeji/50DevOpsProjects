# **Deploying a Static Website with Docker**

## **Overview**

This project demonstrates how to **deploy a simple static website** (HTML, CSS) using **Docker**. The website is packaged into a **Docker container** and served using a lightweight web server (**NGINX**). This approach ensures **portability, scalability, and easy deployment**.

By completing this project, you will learn:

- How to create a **Dockerfile** for a static website.
- How to build a **Docker image**.
- How to run the **containerized web application** locally.
- How to optimize and manage a **Docker-based deployment**.

---

## **Project Structure**

This project follows a structured directory layout:

```plaintext
📂 3_dockerDeployStaticWeb/
|── 📂 .img/           # Images for README
|── 📂 app/            # Website files
|   |── 📄 index.html  # HTML file
|   |── 📄 README.md
|   |── 📄 script.js   # JavaScript file
|   |── 📄 style.css   # CSS file
|── 📄 Dockerfile      # Dockerfile
|── 📄 README.md       # Project instructions
```

---

## **Step 1: Create a Simple Static Website**

I used a simple **HTML, CSS, and JavaScript** website for this project. You can use your own website files or create a new one. The website files are stored [here](./app/) and the documentation is in the [README](./app/README.md).

---

## **Step 2: Create a Dockerfile**

A **Dockerfile** is a script containing instructions on how to **build** a Docker image.

### **Dockerfile**

```dockerfile
# Use NGINX as the base image
FROM nginx:alpine

# Remove default NGINX website
RUN rm -rf /usr/share/nginx/html/*

# Copy website files to NGINX directory
COPY ./app /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
```

This Dockerfile:

- Uses **NGINX:alpine** as the base image. Alpine images are lightweight.
- Removes the default NGINX website.
- Copies the website files from the **app** directory to the NGINX directory.
- Exposes **port 80** for the web server.
- Starts the NGINX server.

---

## **Step 3: Build the Docker Image**

Run the following command in the project directory:

```sh
docker build -t gallery:latest .
```

![Build Docker Image](./.img/01-building-image.png)

This command:

- Uses the **Dockerfile** in the current directory (`.`).
- Tags the image as **gallery:latest**.

---

## **Step 5: Run the Docker Container**

To run the container and map **port 80** of the container to **port 8080** on the host:

```sh
docker run -d -p 8080:80 gallery:latest
```

![Run Docker Container](./.img/02-running-image.png)

Now, open **<http://localhost:8080/>** in a browser to view the website.

![Website Preview](./.img/03-running-container.png)

---

## **Step 6: Verify Running Containers**

To check the running container:

```sh
docker ps
```

To stop the container:

```sh
docker stop <container_id>
```

To remove the container:

```sh
docker rm <container_id>
```

---

## **Step 7: Optimize the Docker Image**

You can further optimize the image by:

1. Using **multi-stage builds** (not needed here since it’s a static website).
2. **Minifying** the website files.
3. **Compressing** the website files.
4. **Removing unnecessary files**.

---

## **Step 8: Push the Image to Docker Hub**

To share the containerized website, push it to Docker Hub.

### **Login to Docker Hub**

```sh
docker login
```

### **Tag the Image**

```sh
docker tag gallery:latest username/gallery:latest
```

### **Push the Image**

```sh
docker push username/gallery:latest
```

---

## **Troubleshooting**

| **Issue** | **Solution** |
|-----------|-------------|
| `docker: command not found` | Install Docker using `sudo apt install docker.io -y` |
| Website not loading | Ensure the container is running using `docker ps` |
| Port conflict | Use a different port (`-p 8081:80`) |

---

## **Key Takeaways**

- **Docker** simplifies website deployment by packaging everything into a container.
- **NGINX:ALPINE** is a lightweight and efficient way to serve static content.
- **Docker Hub** allows sharing and distributing Docker images.

This project is a **stepping stone** to more advanced Docker use cases, such as **multi-container applications** and **CI/CD pipelines**.

---

## **Future Improvements**

🔹 Add **Docker Compose** to manage multiple services.  
🔹 Implement a **CI/CD pipeline** for automated deployments.  
🔹 Deploy using **Kubernetes** for scalability.  

---

## **Conclusion**

This project demonstrates the **power of Docker** in deploying a static website effortlessly. **By containerizing the website, we ensure consistency, portability, and easy deployment across different environments.** 🚀

Want to expand this project? Try deploying it to a **cloud provider** or integrating **Docker Compose** for a more complex setup!
