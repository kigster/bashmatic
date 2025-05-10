document.addEventListener('DOMContentLoaded', function() {
  // Initialize copy to clipboard functionality
  initCopyButtons();
  
  // Initialize animations
  initAnimations();
  
  // Initialize mobile menu
  initMobileMenu();
  
  // Initialize smooth scrolling
  initSmoothScroll();
  
  // Initialize sticky header
  initStickyHeader();
  
  // Initialize code syntax highlighting
  highlightSyntax();
  
  // Initialize terminal demonstration
  initTerminalDemo();
});

// Copy to clipboard functionality for code blocks
function initCopyButtons() {
  const codeBlocks = document.querySelectorAll('.code-container');
  
  codeBlocks.forEach(block => {
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-btn';
    copyButton.innerHTML = '<i class="fas fa-copy"></i> Copy';
    block.appendChild(copyButton);
    
    copyButton.addEventListener('click', () => {
      const code = block.querySelector('code').innerText;
      navigator.clipboard.writeText(code).then(() => {
        copyButton.innerHTML = '<i class="fas fa-check"></i> Copied!';
        copyButton.classList.add('success');
        setTimeout(() => {
          copyButton.innerHTML = '<i class="fas fa-copy"></i> Copy';
          copyButton.classList.remove('success');
        }, 2000);
      }).catch(err => {
        console.error('Failed to copy: ', err);
        copyButton.innerHTML = '<i class="fas fa-times"></i> Failed!';
        copyButton.classList.add('error');
        setTimeout(() => {
          copyButton.innerHTML = '<i class="fas fa-copy"></i> Copy';
          copyButton.classList.remove('error');
        }, 2000);
      });
    });
  });
}

// Animations for elements as they scroll into view
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
  
  // Add staggered animations to feature cards and other grid items
  const grids = document.querySelectorAll('.features-grid, .documentation-links');
  grids.forEach(grid => {
    const items = grid.querySelectorAll('.animate-on-scroll');
    items.forEach((item, index) => {
      item.style.transitionDelay = `${index * 0.1}s`;
    });
  });
}

// Mobile menu toggle
function initMobileMenu() {
  const menuToggle = document.querySelector('.menu-toggle');
  const navLinks = document.querySelector('.nav-links');
  
  if (menuToggle) {
    menuToggle.addEventListener('click', () => {
      navLinks.classList.toggle('active');
      menuToggle.classList.toggle('active');
      if (menuToggle.classList.contains('active')) {
        menuToggle.innerHTML = '<i class="fas fa-times"></i>';
      } else {
        menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
      }
    });
  }
}

// Smooth scrolling for anchor links
function initSmoothScroll() {
  const anchorLinks = document.querySelectorAll('a[href^="#"]');
  
  anchorLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;
      
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        window.scrollTo({
          top: targetElement.offsetTop - 70, // Accounting for fixed header
          behavior: 'smooth'
        });
        
        // Close mobile menu if open
        const navLinks = document.querySelector('.nav-links');
        const menuToggle = document.querySelector('.menu-toggle');
        if (navLinks.classList.contains('active')) {
          navLinks.classList.remove('active');
          menuToggle.classList.remove('active');
          menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        }
        
        // Update URL hash (without scrolling)
        history.pushState(null, null, targetId);
      }
    });
  });
}

// Terminal typing effect for the hero section
function initTypingEffect() {
  const element = document.querySelector('.typing-effect');
  if (!element) return;
  
  const text = element.getAttribute('data-text');
  element.innerHTML = '';
  let i = 0;
  
  function typing() {
    if (i < text.length) {
      element.innerHTML += text.charAt(i);
      i++;
      
      // Random delay to make it feel more like real typing
      const delay = Math.random() * 50 + 30;
      setTimeout(typing, delay);
    }
  }
  
  typing();
}

// Add typing effect to installation command
document.addEventListener('DOMContentLoaded', function() {
  setTimeout(() => {
    initTypingEffect();
  }, 500);
});

// Sticky header effect
function initStickyHeader() {
  const header = document.querySelector('header');
  const heroSection = document.querySelector('.hero');
  let lastScrollTop = 0;
  
  function handleScroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    // Add box shadow and background blur when scrolled
    if (scrollTop > 0) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
    
    // Hide header when scrolling down, show when scrolling up
    if (scrollTop > lastScrollTop && scrollTop > header.offsetHeight) {
      header.classList.add('header-hidden');
    } else {
      header.classList.remove('header-hidden');
    }
    
    lastScrollTop = scrollTop;
    
    // Add active class to current section in menu
    const sections = document.querySelectorAll('section[id]');
    sections.forEach(section => {
      const sectionTop = section.offsetTop - 100;
      const sectionBottom = sectionTop + section.offsetHeight;
      
      if (scrollTop >= sectionTop && scrollTop < sectionBottom) {
        const id = section.getAttribute('id');
        document.querySelectorAll('.nav-links a').forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === `#${id}`) {
            link.classList.add('active');
          }
        });
      }
    });
  }
  
  window.addEventListener('scroll', handleScroll);
  handleScroll(); // Call once on load
}

// Simple syntax highlighting for code blocks
function highlightSyntax() {
  const codeBlocks = document.querySelectorAll('.code-container code');
  
  codeBlocks.forEach(codeBlock => {
    const content = codeBlock.innerHTML;
    
    // Highlight comments
    // let highlighted = content.replace(/(#.+)$/gm, '<span class="code-comment">$1</span>');
    
    // Highlight functions and keywords
    //highlighted = highlighted.replace(/\b(function|local|return|if|then|else|fi|for|while|do|done|in|case|esac|echo|source|export)\b/g, `<span class="code-keyword">$1</span>`);
    
    // Highlight strings
    // highlighted = highlighted.replace(/(".*?")/g, '<span class="code-string">$1</span>');
    //  highlighted = highlighted.replace(/('.*?')/g, '<span class="code-string">$1</span>');
    
     // Highlight variables
     //     highlighted = highlighted.replace(/(\$\{[^}]+\})/g, '<span class="code-variable">$1</span>');
     //     highlighted = highlighted.replace(/(\$[a-zA-Z0-9_]+)/g, '<span class="code-variable">$1</span>');
    
     // Function names
     //     highlighted = highlighted.replace(/([a-zA-Z0-9_.-]+)\(/g, '<span class="code-function">$1</span>(');
    
     //codeBlock.innerHTML = highlighted;
  });
  
  // Add CSS for syntax highlighting
  const style = document.createElement('style');
  style.textContent = `
    .code-comment { color: #6a9955; }
    .code-keyword { color: #569cd6; }
    .code-string { color: #ce9178; }
    .code-variable { color: #9cdcfe; }
    .code-function { color: #dcdcaa; }
    .copy-btn.success { background-color: rgba(40, 167, 69, 0.2); }
    .copy-btn.error { background-color: rgba(220, 53, 69, 0.2); }
  `;
  document.head.appendChild(style);
}

// Count animation for large numbers
function initCountAnimation() {
  const counters = document.querySelectorAll('.counter');
  
  counters.forEach(counter => {
    const target = parseInt(counter.getAttribute('data-count'));
    const duration = 2000; // ms
    const step = Math.ceil(target / (duration / 16)); // 60fps
    let current = 0;
    
    const updateCount = () => {
      current += step;
      if (current >= target) {
        counter.textContent = target;
        return;
      }
      counter.textContent = current;
      requestAnimationFrame(updateCount);
    };
    
    const observer = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) {
        updateCount();
        observer.unobserve(counter);
      }
    });
    
    observer.observe(counter);
  });
}

// Terminal demo interaction
function initTerminalDemo() {
  const terminal = document.querySelector('.terminal-demo');
  if (!terminal) return;
  
  // Make the terminal clickable to "focus" it
  terminal.addEventListener('click', function() {
    this.classList.add('terminal-focused');
    
    // Restart typing animation for the cursor
    const cursor = document.querySelector('.terminal-cursor');
    if (cursor) {
      cursor.style.animation = 'none';
      setTimeout(() => {
        cursor.style.animation = 'blink 1s step-start infinite';
      }, 10);
    }
  });
  
  // Add keyboard interaction
  document.addEventListener('keydown', function(event) {
    if (!terminal.classList.contains('terminal-focused')) return;
    
    if (event.key.length === 1) {
      // Add character to the command line
      const lastLine = terminal.querySelector('.terminal-line:last-child');
      const command = lastLine.querySelector('.terminal-command');
      
      if (!command) {
        // Create command span if it doesn't exist
        const commandSpan = document.createElement('span');
        commandSpan.className = 'terminal-command';
        lastLine.appendChild(commandSpan);
        commandSpan.textContent = event.key;
      } else {
        command.textContent += event.key;
      }
    } else if (event.key === 'Enter') {
      // Process "enter" key
      const lastLine = terminal.querySelector('.terminal-line:last-child');
      const command = lastLine.querySelector('.terminal-command');
      
      if (command && command.textContent.trim()) {
        // Process the command (just for demo purposes)
        processTerminalCommand(command.textContent);
      }
    } else if (event.key === 'Backspace') {
      // Handle backspace
      const lastLine = terminal.querySelector('.terminal-line:last-child');
      const command = lastLine.querySelector('.terminal-command');
      
      if (command && command.textContent.length > 0) {
        command.textContent = command.textContent.slice(0, -1);
      }
    }
  });
  
  // Click outside to unfocus
  document.addEventListener('click', function(event) {
    if (!terminal.contains(event.target)) {
      terminal.classList.remove('terminal-focused');
    }
  });
}

// Process terminal commands for the demo
function processTerminalCommand(command) {
  const terminal = document.querySelector('.terminal-body');
  if (!terminal) return;
  
  // Remove the cursor from the current line
  const currentLine = terminal.querySelector('.terminal-line:last-child');
  const cursor = currentLine.querySelector('.terminal-cursor');
  if (cursor) cursor.remove();
  
  // Predefined responses for demo commands
  let response = '';
  let prefix = '';
  
  command = command.trim().toLowerCase();
  
  if (command === 'help' || command === 'h') {
    response = 'Available commands: help, clear, hello, version, color';
  } else if (command === 'clear' || command === 'cls') {
    // Clear the terminal
    const lines = terminal.querySelectorAll('.terminal-line');
    for (let i = 0; i < lines.length - 1; i++) {
      lines[i].remove();
    }
    addNewCommandLine();
    return;
  } else if (command === 'hello' || command === 'hi') {
    prefix = 'box.yellow-in-blue "Welcome to Bashmatic!"';
    response = `
┌───────────────────────────────────┐
│    Welcome to Bashmatic!          │
└───────────────────────────────────┘`;
  } else if (command === 'version' || command === 'v') {
    prefix = 'info "Bashmatic Version"';
    response = 'INFO: Bashmatic v3.3.1';
  } else if (command === 'color') {
    prefix = 'h.green "Colorful Output"';
    response = `
┌───────────────────────────────────┐
│    COLORFUL OUTPUT                │
└───────────────────────────────────┘`;
  } else {
    prefix = 'run "' + command + '"';
    response = `→ <span class="terminal-runtime">0.01s</span> ${command}\nCommand not found: ${command}`;
  }
  
  // Add command prefix line if needed
  if (prefix) {
    const prefixLine = document.createElement('div');
    prefixLine.className = 'terminal-line';
    prefixLine.innerHTML = `<span class="terminal-prompt">$</span> <span class="terminal-command">${prefix}</span>`;
    terminal.appendChild(prefixLine);
  }
  
  // Add response line
  const responseLine = document.createElement('div');
  responseLine.className = 'terminal-line terminal-output';
  responseLine.innerHTML = response;
  terminal.appendChild(responseLine);
  
  // Add new command line
  addNewCommandLine();
  
  // Scroll to bottom
  terminal.scrollTop = terminal.scrollHeight;
}

// Add a new command line to the terminal
function addNewCommandLine() {
  const terminal = document.querySelector('.terminal-body');
  if (!terminal) return;
  
  const newLine = document.createElement('div');
  newLine.className = 'terminal-line';
  newLine.innerHTML = `<span class="terminal-prompt">$</span> <span class="terminal-cursor"></span>`;
  terminal.appendChild(newLine);
} 
