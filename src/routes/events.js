import express from "express";
import { createEvent } from "../services/eventService.js";

const router = express.Router(); 

// create new event
router.post("/", async (req, res) => {
    try {
        const user = req.user;
        const eventData = req.body;
        const event = await createEvent(eventData, user);
        res.status(201).json(event);
    } catch (err) {
         res.status(400).json({ error: err.message });
    }
});

export default router;