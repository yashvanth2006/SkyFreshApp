import React from 'react';
import { NavLink } from 'react-router-dom';

const Sidebar = () => {
  const navItems = [
    { to: '/', icon: '📊', label: 'Dashboard' },
    { to: '/products', icon: '📦', label: 'Products' },
    { to: '/orders', icon: '📋', label: 'Orders' },
    { to: '/users', icon: '👥', label: 'Users' }
  ];

  return (
    <aside style={styles.sidebar}>
      <div style={styles.logoContainer}>
        <h2 style={styles.logoText}>SKYfresh Admin</h2>
      </div>
      <nav style={styles.nav}>
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            style={({ isActive }) => ({
              ...styles.navLink,
              ...(isActive ? styles.activeLink : {})
            })}
          >
            <span style={styles.icon}>{item.icon}</span>
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
    </aside>
  );
};

const styles = {
  sidebar: {
    width: '240px',
    backgroundColor: '#0f172a',
    color: '#fff',
    display: 'flex',
    flexDirection: 'column',
    padding: '20px 12px'
  },
  logoContainer: {
    paddingBottom: '20px',
    borderBottom: '1px solid #1e293b',
    marginBottom: '20px',
    textAlign: 'center'
  },
  logoText: {
    margin: 0,
    fontSize: '1.25rem',
    color: '#38bdf8'
  },
  nav: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  navLink: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '10px 16px',
    borderRadius: '6px',
    color: '#94a3b8',
    textDecoration: 'none',
    fontWeight: '500',
    transition: 'all 0.2s ease'
  },
  activeLink: {
    backgroundColor: '#1e293b',
    color: '#38bdf8'
  },
  icon: {
    fontSize: '1.2rem'
  }
};

export default Sidebar;