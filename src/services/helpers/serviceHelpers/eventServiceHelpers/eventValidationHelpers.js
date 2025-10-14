import prisma from '../../../prismaClient.js';


// has additional functionality to specifically checks that title and year aren't null when creating an event
export function validateCreateEventData(data) {
    data.title = data.title?.trim();
    data.description = data.description?.trim();
    if (typeof data.title !== 'string' || !data.title) {
      throwDataTypeError('Title');
    }
    if (typeof data.year !== 'number') {
      throwDataTypeError('Year');
    }
    return validateEventData(data);
}

// validate event editung event 
export function validateEditEventData(data) {
    data.title = data.title?.trim();
    data.description = data.description?.trim();
    validateStringField(data.title, 'Title');
    validateNumberField(data.year, 'Year');
    return validateEventData(data);
}
// general validation for any event data (create or edit)
export function validateEventData(data) {
    validateStringField(data.country, 'Country');
    validateStringField(data.city, 'City');
    validateStringField(data.description, 'Description');
    validateStringField(data.place, 'Place');
    validateStringField(data.coverImage, 'coverImage');
    validateStringArrayField(data.albumImages, 'albumImages');
    validateNumberField(data.month, 'Month');
    validateNumberField(data.day, 'Day');
    validateBooleanField(data.hiddenFromMe, 'hiddenFromMe');
    validateBooleanField(data.hiddenFromOthers, 'hiddenFromOthers');
    validateBooleanField(data.anniversaryEnabled, 'anniversaryEnabled');
    validateBooleanField(data.reminderEnabled, 'reminderEnabled');
    return data;
}

function throwDataTypeError(fieldName) {
    throw new Error(`${fieldName} has an invalid data type`);
}

// These functions validate if field is either the correct type or null
// not used for validatecreateeventdata because title and year are required there
function validateStringField(fieldValue, fieldName) {
    if (typeof fieldValue !== 'string' && typeof fieldValue !== 'undefined') {
        throwDataTypeError(fieldName);
    }
}

function validateNumberField(fieldValue, fieldName) {
    if (typeof fieldValue !== 'number' && typeof fieldValue !== 'undefined') {
        throwDataTypeError(fieldName);
    }
}

function validateBooleanField(fieldValue, fieldName) {
    if (typeof fieldValue !== 'boolean' && typeof fieldValue !== 'undefined') {
        throwDataTypeError(fieldName);
    }
}

function validateStringArrayField(fieldValue, fieldName) {
    if (!Array.isArray(fieldValue) && typeof fieldValue !== 'undefined') {
        throwDataTypeError(fieldName);
    }
}