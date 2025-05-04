/**
 * Bashmatic Contributors Page JavaScript
 * 
 * This script fetches contributor data from GitHub's API and renders
 * the contributions chart and contributor cards.
 */

document.addEventListener('DOMContentLoaded', function() {
  // Initialize the contributor's page functionality
  initContributorsPage();
});

async function initContributorsPage() {
  try {
    // Fetch contributor graph data
    const contributorsData = await fetchContributorsGraphData();
    
    // Fetch detailed contributor information
    const contributorsInfo = await fetchContributorsInfo();
    
    // Hide loading indicators
    document.querySelectorAll('.loading-indicator').forEach(el => {
      el.style.display = 'none';
    });
    
    // Render the contributors data
    renderContributorsGraph(contributorsData);
    renderContributorsList(contributorsInfo);
    
    // Initialize metric buttons
    initMetricButtons(contributorsData);
    
    // Initialize animations
    initAnimations();
    
  } catch (error) {
    console.error('Error initializing contributors page:', error);
    showError('Failed to load contributor data. Please try again later.');
  }
}

/**
 * Fetch contributor graph data from GitHub API
 */
async function fetchContributorsGraphData() {
  try {
    // First get the graph data path from GitHub's contributors JSON
    const metadataUrl = 'https://github.com/kigster/bashmatic/graphs/contributors?selectedMetric=additions&format=json';
    const metadataResponse = await fetch(metadataUrl);
    const metadata = await metadataResponse.json();
    
    // Extract the graph data path
    const graphDataPath = metadata.payload.graphDataPath;
    const repoUrl = metadata.payload.repoUrl;
    
    // Construct the full URL to fetch the actual graph data
    const graphDataUrl = `${repoUrl}${graphDataPath}`;
    const graphDataResponse = await fetch(graphDataUrl);
    const graphData = await graphDataResponse.json();
    
    return graphData;
    
  } catch (error) {
    console.error('Error fetching contributors graph data:', error);
    throw new Error('Failed to fetch contributor data from GitHub');
  }
}

/**
 * Fetch detailed information about contributors using GitHub API
 */
async function fetchContributorsInfo() {
  try {
    // Fetch contributor information from GitHub API
    const response = await fetch('https://api.github.com/repos/kigster/bashmatic/contributors');
    console.log(response);
    const contributors = await response.json();
    
    // Get more detailed information for each contributor
    const enrichedContributors = await Promise.all(
      contributors.slice(0, 10).map(async (contributor) => {
        const userResponse = await fetch(contributor.url);
        const userData = await userResponse.json();
        
        return {
          ...contributor,
          name: userData.name || contributor.login,
          avatar: userData.avatar_url,
          profile: userData.html_url,
          bio: userData.bio,
          company: userData.company,
          location: userData.location,
          followers: userData.followers,
          following: userData.following,
          publicRepos: userData.public_repos
        };
      })
    );
    
    return enrichedContributors;
    
  } catch (error) {
    console.error('Error fetching contributors info:', error);
    
    // Fallback to using simpler data if the GitHub API fails
    const fallbackResponse = await fetch('https://api.github.com/repos/kigster/bashmatic/contributors');
    const fallbackData = await fallbackResponse.json();
    
    return fallbackData.map(contributor => ({
      login: contributor.login,
      name: contributor.login,
      avatar: contributor.avatar_url,
      profile: contributor.html_url,
      contributions: contributor.contributions
    }));
  }
}

/**
 * Render the contributors graph using Chart.js
 */
function renderContributorsGraph(data) {
  const ctx = document.getElementById('contributionsChart').getContext('2d');
  
  // Process the data for the chart
  const processedData = processContributorData(data, 'additions');
  
  // Create the chart
  window.contributionsChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: processedData.labels,
      datasets: [{
        label: 'Additions',
        data: processedData.values,
        backgroundColor: 'rgba(247, 147, 30, 0.7)',
        borderColor: 'rgba(247, 147, 30, 1)',
        borderWidth: 1,
        borderRadius: 4,
        barPercentage: 0.7,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return `${context.dataset.label}: ${formatNumber(context.raw)}`;
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              return formatNumber(value);
            }
          }
        }
      }
    }
  });
}

/**
 * Process contributor data for Chart.js
 */
function processContributorData(data, metric) {
  // Extract top 10 contributors by the selected metric
  const sortedContributors = [...data].sort((a, b) => b[metric] - a[metric]).slice(0, 10);
  
  // Extract labels (contributor names) and values
  const labels = sortedContributors.map(contributor => contributor.author.login);
  const values = sortedContributors.map(contributor => contributor[metric]);
  
  return { labels, values };
}

/**
 * Render the list of contributors
 */
function renderContributorsList(contributors) {
  const contributorsList = document.getElementById('contributorsList');
  contributorsList.innerHTML = '';
  
  // Sort contributors by contributions
  const sortedContributors = [...contributors].sort((a, b) => b.contributions - a.contributions);
  
  // Create a card for each contributor
  sortedContributors.forEach(contributor => {
    const contributorCard = document.createElement('div');
    contributorCard.className = 'contributor-card animate-on-scroll';
    
    contributorCard.innerHTML = `
      <div class="contributor-header">
        <img src="${contributor.avatar}" alt="${contributor.name}" class="contributor-avatar">
        <div>
          <h3 class="contributor-name">${contributor.name || contributor.login}</h3>
          <div class="contributor-username">@${contributor.login}</div>
        </div>
      </div>
      <div class="contributor-stats">
        <div class="stat-item">
          <div class="stat-value">${formatNumber(contributor.contributions)}</div>
          <div class="stat-label">Contributions</div>
        </div>
        ${contributor.followers ? `
        <div class="stat-item">
          <div class="stat-value">${formatNumber(contributor.followers)}</div>
          <div class="stat-label">Followers</div>
        </div>
        ` : ''}
        ${contributor.publicRepos ? `
        <div class="stat-item">
          <div class="stat-value">${formatNumber(contributor.publicRepos)}</div>
          <div class="stat-label">Repos</div>
        </div>
        ` : ''}
      </div>
      <div class="contributor-link">
        <a href="${contributor.profile}" target="_blank">
          <i class="fab fa-github"></i> View Profile
        </a>
      </div>
    `;
    
    contributorsList.appendChild(contributorCard);
  });
  
  // Re-initialize animations for the new elements
  initAnimations();
}

/**
 * Initialize metric buttons for the graph
 */
function initMetricButtons(data) {
  const metricButtons = document.querySelectorAll('.metric-btn');
  
  metricButtons.forEach(button => {
    button.addEventListener('click', function() {
      // Remove active class from all buttons
      metricButtons.forEach(btn => btn.classList.remove('active'));
      
      // Add active class to clicked button
      this.classList.add('active');
      
      // Get the selected metric
      const metric = this.getAttribute('data-metric');
      
      // Update the chart with the new metric
      updateChart(data, metric);
    });
  });
}

/**
 * Update the chart with new metric data
 */
function updateChart(data, metric) {
  // Process the data for the selected metric
  const processedData = processContributorData(data, metric);
  
  // Update chart data
  window.contributionsChart.data.labels = processedData.labels;
  window.contributionsChart.data.datasets[0].data = processedData.values;
  
  // Update label based on the metric
  window.contributionsChart.data.datasets[0].label = metric.charAt(0).toUpperCase() + metric.slice(1);
  
  // Update colors based on the metric
  if (metric === 'additions') {
    window.contributionsChart.data.datasets[0].backgroundColor = 'rgba(247, 147, 30, 0.7)';
    window.contributionsChart.data.datasets[0].borderColor = 'rgba(247, 147, 30, 1)';
  } else if (metric === 'deletions') {
    window.contributionsChart.data.datasets[0].backgroundColor = 'rgba(220, 53, 69, 0.7)';
    window.contributionsChart.data.datasets[0].borderColor = 'rgba(220, 53, 69, 1)';
  } else if (metric === 'commits') {
    window.contributionsChart.data.datasets[0].backgroundColor = 'rgba(25, 135, 84, 0.7)';
    window.contributionsChart.data.datasets[0].borderColor = 'rgba(25, 135, 84, 1)';
  }
  
  // Update the chart
  window.contributionsChart.update();
}

/**
 * Format numbers for display (e.g., 1000 -> 1K)
 */
function formatNumber(num) {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
}

/**
 * Show error message
 */
function showError(message) {
  const containers = [
    document.querySelector('.contributors-graph'),
    document.querySelector('.contributors-list')
  ];
  
  containers.forEach(container => {
    if (container) {
      container.innerHTML = `
        <div class="error-message">
          <i class="fas fa-exclamation-circle"></i>
          <p>${message}</p>
        </div>
      `;
    }
  });
}

/**
 * Initialize animations for the contributors page
 */
function initAnimations() {
  const animatedElements = document.querySelectorAll('.animate-on-scroll');
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animated');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  });
  
  animatedElements.forEach(element => {
    observer.observe(element);
  });
} 