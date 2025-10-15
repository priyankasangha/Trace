import * as DataUtils from '../../utils/dataUtils.js';

// has additional functionality to specifically checks that title and year aren't null when creating an event
export function validateCreateEventData(data) {
    data.title = data.title?.trim();
    data.description = data.description?.trim();
    if (typeof data.title !== 'string' || !data.title) {
      DataUtils.throwDataTypeError('Title');
    }
    if (typeof data.year !== 'number') {
      DataUtils.throwDataTypeError('Year');
    }
    return validateEventData(data);
}

// validate event editung event 
export function validateEditEventData(data) {
    data.title = data.title?.trim();
    data.description = data.description?.trim();
    DataUtils.validateStringField(data.title, 'Title');
    DataUtils.validateNumberField(data.year, 'Year');
    return validateEventData(data);
}
// general validation for any event data (create or edit)
function validateEventData(data) {
    DataUtils.validateStringField(data.country, 'Country');
    DataUtils.validateStringField(data.city, 'City');
    DataUtils.validateStringField(data.description, 'Description');
    DataUtils.validateStringField(data.place, 'Place');
    DataUtils.validateStringField(data.coverImage, 'coverImage');
    DataUtils.validateStringArrayField(data.albumImages, 'albumImages');
    DataUtils.validateNumberField(data.month, 'Month');
    DataUtils.validateNumberField(data.day, 'Day');
    DataUtils.validateStringField(data.journal, 'Journal');
    DataUtils.validateBooleanField(data.hiddenFromMe, 'hiddenFromMe');
    DataUtils.validateBooleanField(data.hiddenFromOthers, 'hiddenFromOthers');
    DataUtils.validateBooleanField(data.anniversaryEnabled, 'anniversaryEnabled');
    DataUtils.validateBooleanField(data.reminderEnabled, 'reminderEnabled');
    return data;
}
