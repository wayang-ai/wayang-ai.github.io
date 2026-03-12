document.addEventListener('DOMContentLoaded', () => {
  const root = document.documentElement;
  const themeToggle = document.getElementById('theme-toggle');

  const getTheme = () => root.getAttribute('data-theme') || 'dark';
  const setTheme = (theme) => {
    root.setAttribute('data-theme', theme);
    try {
      localStorage.setItem('wayang-theme', theme);
    } catch (error) {
      // Ignore storage errors in private browsing modes.
    }
    if (themeToggle) {
      themeToggle.textContent = theme === 'light' ? 'Light' : 'Dark';
      themeToggle.setAttribute('aria-label', `Switch to ${theme === 'light' ? 'dark' : 'light'} theme`);
    }
  };

  if (themeToggle) {
    setTheme(getTheme());
    themeToggle.addEventListener('click', () => {
      setTheme(getTheme() === 'light' ? 'dark' : 'light');
    });
  }

  const mermaidBlocks = document.querySelectorAll('pre > code.language-mermaid');
  const mermaidNodes = [];

  mermaidBlocks.forEach((codeEl, index) => {
    const pre = codeEl.parentElement;
    if (!pre) {
      return;
    }
    const container = document.createElement('div');
    container.className = 'mermaid';
    container.id = `mermaid-diagram-${index + 1}`;
    container.textContent = codeEl.textContent || '';
    pre.replaceWith(container);
    mermaidNodes.push(container);
  });

  if (mermaidNodes.length > 0 && window.mermaid) {
    window.mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'loose',
      theme: getTheme() === 'light' ? 'default' : 'dark'
    });
    window.mermaid.run({ nodes: mermaidNodes });
  }

  const blocks = document.querySelectorAll('pre > code');

  blocks.forEach((codeEl) => {
    const pre = codeEl.parentElement;
    if (!pre || pre.dataset.enhanced === 'true') {
      return;
    }

    pre.dataset.enhanced = 'true';
    pre.classList.add('code-block');

    const toolbar = document.createElement('div');
    toolbar.className = 'code-toolbar';

    const lang = document.createElement('span');
    lang.className = 'code-lang';
    const className = codeEl.className || '';
    const match = className.match(/language-([a-zA-Z0-9_-]+)/);
    lang.textContent = match ? match[1] : 'code';

    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'copy-button';
    button.textContent = 'Copy';

    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(codeEl.innerText);
        button.textContent = 'Copied';
        button.classList.add('copied');
        setTimeout(() => {
          button.textContent = 'Copy';
          button.classList.remove('copied');
        }, 1400);
      } catch (error) {
        button.textContent = 'Failed';
        setTimeout(() => {
          button.textContent = 'Copy';
        }, 1400);
      }
    });

    toolbar.appendChild(lang);
    toolbar.appendChild(button);
    pre.prepend(toolbar);
  });

  const typingTarget = document.getElementById('typing-effect');
  if (typingTarget) {
    const command = typingTarget.getAttribute('data-command') || 'wayang dev';
    const result = typingTarget.getAttribute('data-result') || '';
    const initTyping = () => {
      if (!window.T) {
        return;
      }
      typingTarget.textContent = '';
      const escapedResult = result
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\n/g, '<br>');
      const text = escapedResult
        ? `${command}<ins>450</ins><br><span class='terminal-output'>${escapedResult}</span>`
        : command;
      new window.T('#typing-effect', {
        speed: 90,
        cursor: '_',
        text
      });
    };

    if (window.T) {
      initTyping();
    } else {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/gh/mntn-dev/t.js/t.min.js';
      script.onload = initTyping;
      document.head.appendChild(script);
    }
  }
});
