import React from 'react';
import { NavLink } from 'react-router-dom';

const Sidebar = ({ isOpen, onClose }) => {
  const navItems = [
    { to: '/', icon: '📊', label: 'Dashboard' },
    { to: '/products', icon: '📦', label: 'Products' },
    { to: '/orders', icon: '📋', label: 'Orders' },
    { to: '/users', icon: '👥', label: 'Users' }
  ];

  return (
    <>
      <div 
        className={`sidebar-overlay ${isOpen ? 'open' : ''}`}
        onClick={onClose}
      />
      <aside className={`sidebar-container ${isOpen ? 'open' : ''}`}>
        <div className="sidebar-logo-container">
          <h2 className="sidebar-logo-text">SKYfresh Admin</h2>
        </div>
        <nav className="nav-menu">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              onClick={onClose}
              className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
            >
              <span className="nav-icon">{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  );
};

export default Sidebar;