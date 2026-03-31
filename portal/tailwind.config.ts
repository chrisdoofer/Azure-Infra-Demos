import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        azure: {
          DEFAULT: '#0078D4',
          hover: '#106EBE',
          pressed: '#005A9E',
          light: '#DEECF9',
          lightest: '#EFF6FC',
        },
        neutral: {
          white: '#FFFFFF',
          page: '#FAF9F8',
          subtle: '#F3F2F1',
          divider: '#EDEBE9',
          'text-primary': '#323130',
          'text-secondary': '#605E5C',
          'text-disabled': '#A19F9D',
          'border-default': '#E1DFDD',
          'border-strong': '#8A8886',
        },
        semantic: {
          success: '#107C10',
          'warning-text': '#797775',
          'warning-bg': '#FFF4CE',
          danger: '#A4262C',
          info: '#0078D4',
        },
        category: {
          networking: '#0078D4',
          compute: '#008272',
          data: '#8764B8',
          security: '#D83B01',
          monitoring: '#00B7C3',
          governance: '#498205',
          ai: '#881798',
          web: '#0078D4',
        },
      },
      fontFamily: {
        sans: ['Segoe UI', 'Segoe UI Web (West European)', '-apple-system', 'BlinkMacSystemFont', 'Roboto', 'Helvetica Neue', 'sans-serif'],
      },
      fontSize: {
        hero: ['42px', { lineHeight: '56px', fontWeight: '600' }],
        'title-1': ['28px', { lineHeight: '36px', fontWeight: '600' }],
        'title-2': ['20px', { lineHeight: '28px', fontWeight: '600' }],
        'subtitle-1': ['16px', { lineHeight: '22px', fontWeight: '600' }],
        'body-1': ['14px', { lineHeight: '20px', fontWeight: '400' }],
        'body-2': ['12px', { lineHeight: '16px', fontWeight: '400' }],
        caption: ['12px', { lineHeight: '16px', fontWeight: '400' }],
      },
      borderRadius: {
        sm: '4px',
        DEFAULT: '4px',
        md: '8px',
        lg: '8px',
      },
      boxShadow: {
        card: '0 1.6px 3.6px 0 rgba(0,0,0,0.132), 0 0.3px 0.9px 0 rgba(0,0,0,0.108)',
        elevated: '0 6.4px 14.4px 0 rgba(0,0,0,0.132), 0 1.2px 3.6px 0 rgba(0,0,0,0.108)',
      },
      spacing: {
        '4': '4px',
        '8': '8px',
        '12': '12px',
        '16': '16px',
        '20': '20px',
        '24': '24px',
        '32': '32px',
        '48': '48px',
      },
      maxWidth: {
        content: '1280px',
      },
    },
  },
  plugins: [],
};

export default config;
