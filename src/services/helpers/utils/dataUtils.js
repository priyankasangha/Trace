import { JourneyVisibility } from '../../../../prisma/client.js';

export function throwDataTypeError(fieldName) {
  throw new Error(`${fieldName} has an invalid data type`);
}

// These functions validate if field is either the correct type or null
// not used for validatecreateeventdata because title and year are required there
export function validateStringField(fieldValue, fieldName) {
  if (typeof fieldValue !== 'string' && typeof fieldValue !== 'undefined') {
    throwDataTypeError(fieldName);
  }
}

export function validateNumberField(fieldValue, fieldName) {
  if (typeof fieldValue !== 'number' && typeof fieldValue !== 'undefined') {
    throwDataTypeError(fieldName);
  }
}

export function validateBooleanField(fieldValue, fieldName) {
  if (typeof fieldValue !== 'boolean' && typeof fieldValue !== 'undefined') {
    throwDataTypeError(fieldName);
  }
}

export function validateArrayField(fieldValue, fieldName) {
  if (typeof fieldValue === 'undefined') return;
  if (!Array.isArray(fieldValue)) {
    throwDataTypeError(fieldName);
  }
}

export function validateEnumField(fieldValue, enumObj, fieldName) {
  if (typeof fieldValue === 'undefined') return;
  const validValues = Object.values(enumObj);
  if (!validValues.includes(fieldValue)) {
    throw new Error(`${fieldName} must be one of: ${validValues.join(', ')}`);
  }
}
