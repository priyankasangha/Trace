import * as DataUtils from '../../utils/dataUtils.js';
import { JourneyVisibility } from '../../../../prisma/client.js';

export function validateCreateJourneyData(data) {
    data.name = data.name?.trim();
    data.description = data.description?.trim();
    if (typeof data.name !== 'string' || !data.name) {
      DataUtils.throwDataTypeError('Name');
    };
    return validateJourneyData(data);
}

export function validateEditJourneyData(data) {
    data.name = data.name?.trim();
    data.description = data.description?.trim();
    DataUtils.validateStringField(data.name, 'Name');
    return validateJourneyData(data);
}

function validateJourneyData(data) {
    DataUtils.validateStringField(data.description, 'Description');
    DataUtils.validateStringField(data.coverPage, 'coverpage');
    DataUtils.validateArrayField(data.events, 'events');
    DataUtils.validateArrayField(data.participants, 'participants');
    DataUtils.validateBooleanField(data.anniversaryEnabled, 'anniversaryEnabled');
    DataUtils.validateBooleanField(data.completed, 'completed');
    DataUtils.validateEnumField(data.visibility, JourneyVisibility, 'visibility');
    return data;
}