import { required, minLength } from '@vuelidate/validators';

// Mirrors Label's title format (RegexHelper::UNICODE_CHARACTER_NUMBER_HYPHEN_UNDERSCORE),
// so the form rejects what the server would reject.
const LABEL_TITLE_REGEX = /^[\p{L}\p{N}]+[\p{L}\p{N}_-]+$/u;

export const validLabelCharacters = (str = '') => LABEL_TITLE_REGEX.test(str);

export const getLabelTitleErrorMessage = validation => {
  let errorMessage = '';
  if (!validation.title.$error) {
    errorMessage = '';
  } else if (!validation.title.required) {
    errorMessage = 'LABEL_MGMT.FORM.NAME.REQUIRED_ERROR';
  } else if (!validation.title.minLength) {
    errorMessage = 'LABEL_MGMT.FORM.NAME.MINIMUM_LENGTH_ERROR';
  } else if (!validation.title.validLabelCharacters) {
    errorMessage = 'LABEL_MGMT.FORM.NAME.VALID_ERROR';
  }
  return errorMessage;
};

export default {
  title: {
    required,
    minLength: minLength(2),
    validLabelCharacters,
  },
  description: {},
  color: {
    required,
  },
  showOnSidebar: {},
};
