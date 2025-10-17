import { jest } from '@jest/globals';



const prismaMock = {
    event: {
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        findMany: jest.fn(),
        findUnique: jest.fn(),
    },
};

export default prismaMock;