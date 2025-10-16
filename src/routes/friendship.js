const express = require('express');
const router = express.Router();
import * as Friend from '../services/friendshipService.js';
import { FriendshipStatus } from '../../../prismaClient.js'; 
// import * as FriendshipValidation from '../helpers/serviceHelpers/validationHelpers/friendshipValidationHelpers.js'; --- IGNORE ---


router.post('/users/:userId/friends/:friendId/request', async (req, res) => {
  try {
    const { userId, friendId } = req.params;
    const result = await Friend.sendFriendRequest(parseInt(userId, 10), parseInt(friendId, 10));
    res.status
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.put('/users/:userId/friends/:friendId/accept', async (req, res) => {
    try {
        const { userId, friendId } = req.params;
        const result = await Friend.acceptFriendRequest(parseInt(userId, 10), parseInt(friendId, 10));
        res.status(200).json(result);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

router.put('/users/:userId/friends/:friendId/reject', async (req, res) => {
    try {
        const { userId, friendId } = req.params;
        const result = await Friend.rejectFriendRequest(parseInt(userId, 10), parseInt(friendId, 10));
        res.status(200).json(result);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

router.get('/users/:userId/friends', async (req, res) => {
    try {
        const { userId } = req.params;
        const friends = await Friend.getMyFriends(parseInt(userId, 10));
        res.status(200).json(friends);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

router.get('/users/:userId/friends/requests', async (req, res) => {
    try {
        const { userId } = req.params;
        const requests = await Friend.getPendingFriendRequests(parseInt(userId, 10));
        res.status(200).json(requests);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

router.get('/users/:userId/friends/:friendId/status', async (req, res) => {
    try {
        const { userId, friendId } = req.params;
        const status = await Friend.getFriendshipStatus(parseInt(userId, 10), parseInt(friendId, 10));
        res.status(200).json(status);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
