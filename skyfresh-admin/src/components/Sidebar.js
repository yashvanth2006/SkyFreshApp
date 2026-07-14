import React from 'react';
import { NavLink } from 'react-router-dom';

const links = [
  { to: '/',         icon: '📊', label: 'Dashboard' },
  { to: '/products', icon: '🍎', label: 'Products'  },
  { to: '/orders',   icon: '📦', label: 'Orders'    },
  { to: '/users',    icon: '👥', label: 'Users'     },
];

export default function Sidebar() {
  return (
    <div style={styles.sidebar}>
      {/* Logo */}
      <div style={styles.logo}>
        <span style={styles.logoIcon}>🌿</span>
        <div>
          <div style={styles.logoText}>
            <span style={styles.sky}>SKY</span>fresh
          </div>
          <div style={styles.logoSub}>Admin Panel</div>
        </div>
      </div>

      {/* Links */}
      <nav style={styles.nav}>
        {links.map(link => (
          <NavLink
            key={link.to}
            to={link.to}
            end={link.to === '/'}
            style={({ isActive }) => ({
              ...styles.link,
              background: isActive ? 'linear-gradient(90deg, #0EA5E9, #38BDF8)' : 'transparent',
              color: isActive ? '#fff' : '#64748B',
              boxShadow: isActive ? '0 4px 12px rgba(14,165,233,0.3)' : 'none',
            })}
          >
            <span style={styles.linkIcon}>{link.icon}</span>
            {link.label}
          </NavLink>
        ))}
      </nav>

      {/* Bottom */}
      <div style={styles.bottom}>
        <div style={styles.adminBadge}>
          <span style={{ fontSize: 20 }}>👤</span>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700 }}>Admin</div>
            <div style={{ fontSize: 11, color: '#94A3B8' }}>SKYfresh</div>
          </div>
        </div>
      </div>
    </div>
  );
}

const styles = {
  sidebar: {
    width: 240,
    minHeight: '100vh',
    background: '#fff',
    borderRight: '1px solid #E2E8F0',
    display: 'flex',
    flexDirection: 'column',
    padding: '24px 16px',
    position: 'fixed',
    top: 0, left: 0, bottom: 0,
  },
  logo: {
    display: 'flex', alignItems: 'center', gap: 12,
    marginBottom: 32, padding: '0 8px',
  },
  logoIcon: {
    fontSize: 32,
    background: 'linear-gradient(135deg, #0EA5E9, #38BDF8)',
    borderRadius: 12, padding: 8,
  },
  logoText: {
    fontSize: 20, fontWeight: 800, color: '#0C1A2E',
  },
  sky: { color: '#0EA5E9' },
  logoSub: { fontSize: 11, color: '#94A3B8', letterSpacing: 1 },
  nav: { display: 'flex', flexDirection: 'column', gap: 6, flex: 1 },
  link: {
    display: 'flex', alignItems: 'center', gap: 12,
    padding: '12px 16px', borderRadius: 14,
    textDecoration: 'none', fontSize: 14, fontWeight: 600,
    transition: 'all 0.2s',
  },
  linkIcon: { fontSize: 18 },
  bottom: { borderTop: '1px solid #E2E8F0', paddingTop: 16 },
  adminBadge: {
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '10px 12px', background: '#F8FAFC',
    borderRadius: 12,
  },
};