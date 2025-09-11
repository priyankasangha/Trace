// import express to run a web server
import express from "express";

// server object
const app = express();

// health check for route
app.get("/", (_req, res) => {
    res.send("Backend is running!");
});

// start server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
});