function expandPersonDetails() {
  const container = document.querySelector('.personExtended-container');
  if (container) {
    container.classList.remove('d-none');
  }
  document.querySelectorAll('.mir-fieldset-legend').forEach(element => {
    element.classList.remove('hiddenDetail');
  });
  document.querySelectorAll('.mir-fieldset-expand-item').forEach(element => {
    element.classList.remove('fa-chevron-down');
    element.classList.add('fa-chevron-up');
  });
}

function replaceMaskedEmails() {
  document.querySelectorAll('span.madress').forEach(span => {
    const address = span.textContent.replace(' [at] ', '@');
    const link = document.createElement('a');
    link.href = `mailto:${address}`;
    link.textContent = address;
    span.replaceWith(link);
  });
}

// set new default values for institution and location
function setDefaultInstitutionValues() {
  const genreInput = document.querySelector("input[name='genre']");
  const genre = genreInput?.value;
  if (!genre) {
    return;
  }

  const placeSelector = 'input[name="/mycoreobject/metadata[1]/def.modsContainer[1]/modsContainer[1]' +
    '/mods:mods[1]/mods:originInfo[2]/mods:place[1]/mods:placeTerm[1]"]';
  const publisherSelector = 'input[name="/mycoreobject/metadata[1]/def.modsContainer[1]/modsContainer[1]' +
    '/mods:mods[1]/mods:originInfo[2]/mods:publisher[1]"]';

  const placeInput = document.querySelector(placeSelector);
  const publisherInput = document.querySelector(publisherSelector);

  const genreDefaults = {
    'matura': {
      place: 'Kreuzlingen',
      publisher: 'Kantonsschule Kreuzlingen'
    },
    'bachelor_thesis': {
      place: 'Kreuzlingen',
      publisher: 'Pädagogische Hochschule Thurgau'
    },
    'master_thesis': {
      place: 'Kreuzlingen, Konstanz',
      publisher: 'Pädagogische Hochschule Thurgau, Universität Konstanz'
    }
  };

  if (genreDefaults[genre]) {
    if (placeInput && (!placeInput.value || placeInput.value.trim() === '')) {
      placeInput.value = genreDefaults[genre].place;
    }
    if (publisherInput && (!publisherInput.value || publisherInput.value.trim() === '')) {
      publisherInput.value = genreDefaults[genre].publisher;
    }
  }
}

function observeAndSetDefaultHost(defaultValue) {
  const observer = new MutationObserver(() => {
    const hostSelect = document.querySelector('select#host');
    if (hostSelect) {
      const defaultOption = hostSelect.querySelector(`option[value="${defaultValue}"]`);
      if (defaultOption) {
        hostSelect.value = defaultValue;
      }
    }
  });
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
}

function ignoreEmptyFieldsOnSubmit(event) {
  const form = event.currentTarget;
  const inputs = form.querySelectorAll('input');
  inputs.forEach(input => {
    if (!input.value) {
      input.dataset.nameBackup = input.name;
      input.removeAttribute('name');
    }
  });
  // Restore field names after the form is submitted
  // setTimeout ensures this runs after the submit event completes
  setTimeout(() => {
    inputs.forEach(input => {
      if (input.dataset.nameBackup) {
        input.name = input.dataset.nameBackup;
        delete input.dataset.nameBackup;
      }
    });
  }, 0);
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelector('form.searchfield_box')?.addEventListener('submit', ignoreEmptyFieldsOnSubmit);
  replaceMaskedEmails();
  setDefaultInstitutionValues();
  expandPersonDetails();
  observeAndSetDefaultHost();
});
