// import express to run a web server
import express from "express";
import session from "express-session";
import passport from "./config/passport.js";
import dotenv from "dotenv";
import eventRoutes from "./routes/events.js";

// load .env variables
dotenv.config();

// server object
const app = express();

// parse JSON bodies
app.use(express.json());

// middleware:
function ensureAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
     }
     res.status(401).json({ error: "you must be logged in"});
}

// session required for passport
app.use(
    session({
        secret: process.env.SESSION_SECRET || "something_secret_fallback",
        resave: false,
        saveUninitialized: false,
    })
);

// initialize passport and session
app.use(passport.initialize());
app.use(passport.session());

// ----- ROUTES -----

// health check for route
app.get("/", (_req, res) => {
    res.send("Backend is running!");
});

// start authentication with Google
app.get(
    "/auth/google",
    passport.authenticate("google", { scope: ["profile", "email"] })
);

// Google redirects here after authentication
app.get(
    "/auth/google/callback",
    passport.authenticate("google", { failureRedirect: "/" }),
    (req, res) => {
        // Successful authentication, redirect home.
        const user = req.user;
        res.send(`Hello ${user?.name}, you have been logged in! You can close this window and return to the app.`);
    }
);

// mount route to add event
app.use("/api/events", ensureAuthenticated, eventRoutes);

// ---- START SERVER ----
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
});