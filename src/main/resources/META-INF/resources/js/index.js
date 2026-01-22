document.addEventListener("DOMContentLoaded", function () {
  let documentsDefault = 0;

  const searchInput = document.getElementById('project-searchInput');
  const switchSpeech = document.getElementById('switchSpeech');
  const switchThesis = document.getElementById('switchThesis');

  const filterSpeech = document.getElementById('filterSpeech');
  const filterThesis = document.getElementById('filterThesis');

  function formatNumber(num) {
    return num.toLocaleString();
  }

  function updatePlaceholder(count) {
    searchInput.setAttribute('placeholder', 'Suche in ' + count + ' Dokumenten');
  }

  const filters = {
    speech: 'mir_genres:speech',
    thesis: 'mir_genres:thesis'
  };

  function buildUrlWithFilters(...exclude) {
    const base = 'objectType:mods AND state:published';
    const filterQuery = exclude.map(f => `NOT(category.top:"${filters[f]}")`).join(' AND ');
    return `../api/v1/search?q=${base}${filterQuery ? ' AND ' + filterQuery : ''}&rows=0&wt=json`;
  }

  const urls = {
    default: buildUrlWithFilters('speech', 'thesis'),
    filterThesis: buildUrlWithFilters('thesis'),
    filterSpeech: buildUrlWithFilters('speech'),
    noFilter: buildUrlWithFilters()
  };

  async function fetchCount(url) {
    try {
      const response = await fetch(url);
      const data = await response.json();
      return formatNumber(data.response.numFound);
    } catch (error) {
      console.error('Fetch error:', error);
      return 0;
    }
  }

  fetchCount(urls.default).then(count => {
    documentsDefault = count;
    updatePlaceholder(documentsDefault);
  });

  async function handleSwitchChange() {
    filterThesis.disabled = switchThesis.checked;
    filterSpeech.disabled = switchSpeech.checked;
    if (switchThesis.checked && !switchSpeech.checked) {
      const count = await fetchCount(urls.filterSpeech);
      updatePlaceholder(count);
    } else if (!switchThesis.checked && switchSpeech.checked) {
      const count = await fetchCount(urls.filterThesis);
      updatePlaceholder(count);
    } else if (switchThesis.checked && switchSpeech.checked) {
      const count = await fetchCount(urls.noFilter);
      updatePlaceholder(count);
    } else {
      updatePlaceholder(documentsDefault);
    }
  }

  switchSpeech.addEventListener('change', handleSwitchChange);
  switchThesis.addEventListener('change', handleSwitchChange);
});
