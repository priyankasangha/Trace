// services/feedbackService.js
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

export const feedbackService = {
  async createFeedback({ userId, content, urgency }) {
    return await prisma.feedback.create({
      data: {
        userId,
        content,
        urgency,
      },
      include: {
        user: {
          select: { name: true, email: true }
        }
      }
    });
  },

  async getAllFeedback() {
    return await prisma.feedback.findMany({
      orderBy: [
        { resolved: 'asc' },
        { urgency: 'desc' },
        { createdAt: 'desc' }
      ],
      include: {
        user: {
          select: { name: true, profilePic: true }
        }
      }
    });
  },

  async toggleResolveStatus(feedbackId, isResolved) {
    return await prisma.feedback.update({
      where: { id: Number(feedbackId) },
      data: { resolved: isResolved }
    });
  },

  async deleteFeedback(feedbackId) {
    return await prisma.feedback.delete({
      where: { id: Number(feedbackId) }
    });
  }
};