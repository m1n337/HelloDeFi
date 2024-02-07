import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Hello DeFi',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://your-docusaurus-site.example.com',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'm1n337', // Usually your GitHub org/user name.
  projectName: 'HelloDeFi', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    docs: {
      sidebar: {
        hideable: true,
        autoCollapseCategories: true,
      }  
    },
    navbar: {
      title: '🗿 Home',
      // logo: {
      //   alt: 'Home Logo',
      //   src: 'img/logo.svg',
      // },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'dapps',
          position: 'left',
          label: '👨🏻‍🚀 Dapps',
        },

        {
          type: 'docSidebar',
          sidebarId: 'armory',
          position: 'left',
          label: '🥷🏻 Armory',
        },
        // {to: '/docs/dapps', label: 'Dapps', position: 'left'},
        // {to: '/docs/toolkits', label: 'Toolkits', position: 'left'},
        {
          href: 'https://github.com/m1n337',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
