import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { API_URL } from '../config';

const Login = () => {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const navigate = useNavigate();

  const handleSendOtp = async (e) => {
    e.preventDefault();
    if (phone.length < 10) {
      setError('Please enter a valid phone number');
      return;
    }
    
    setLoading(true);
    setError('');
    
    try {
      const res = await fetch(`${API_URL}/auth/send-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone })
      });
      const data = await res.json();
      
      if (data.success) {
        setOtpSent(true);
      } else {
        setError(data.message || 'Failed to send OTP');
      }
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    if (otp.length < 6) {
      setError('Please enter a valid 6-digit OTP');
      return;
    }
    
    setLoading(true);
    setError('');
    
    try {
      const res = await fetch(`${API_URL}/auth/verify-otp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone, otp })
      });
      const data = await res.json();
      
      if (data.success) {
        // Check if user is admin
        if (data.user && data.user.role === 'admin') {
          localStorage.setItem('admin_token', data.token);
          navigate('/');
        } else {
          setError('Unauthorized. Admin access required.');
          setOtpSent(false); // Reset to phone entry
          setOtp('');
        }
      } else {
        setError(data.message || 'Invalid OTP');
      }
    } catch (err) {
      setError('Network error. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.header}>
          <span style={styles.logo}>🌿</span>
          <h2 style={styles.title}>SKYfresh Admin</h2>
        </div>
        
        <p style={styles.subtitle}>
          {otpSent ? 'Enter the 6-digit code sent to your phone' : 'Sign in to access the dashboard'}
        </p>

        {error && <div style={styles.error}>{error}</div>}

        {!otpSent ? (
          <form onSubmit={handleSendOtp} style={styles.form}>
            <input
              type="tel"
              placeholder="Phone Number"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              style={styles.input}
              required
            />
            <button type="submit" disabled={loading} style={styles.button}>
              {loading ? 'Sending...' : 'Send OTP'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp} style={styles.form}>
            <input
              type="text"
              placeholder="6-digit OTP"
              value={otp}
              onChange={(e) => setOtp(e.target.value)}
              maxLength={6}
              style={{ ...styles.input, textAlign: 'center', letterSpacing: '8px', fontSize: '18px' }}
              required
            />
            <button type="submit" disabled={loading} style={styles.button}>
              {loading ? 'Verifying...' : 'Verify & Login'}
            </button>
            <button 
              type="button" 
              onClick={() => { setOtpSent(false); setOtp(''); setError(''); }} 
              style={styles.textButton}
            >
              Change Phone Number
            </button>
          </form>
        )}
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '100vh',
    backgroundColor: '#f8fafc'
  },
  card: {
    backgroundColor: '#fff',
    padding: '40px',
    borderRadius: '16px',
    boxShadow: '0 4px 6px rgba(0,0,0,0.05)',
    width: '100%',
    maxWidth: '400px',
    textAlign: 'center'
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '12px',
    marginBottom: '16px'
  },
  logo: {
    fontSize: '28px'
  },
  title: {
    margin: 0,
    fontSize: '24px',
    color: '#0f172a'
  },
  subtitle: {
    color: '#64748b',
    marginBottom: '24px',
    fontSize: '15px'
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '16px'
  },
  input: {
    padding: '14px',
    borderRadius: '8px',
    border: '1px solid #cbd5e1',
    fontSize: '16px',
    outline: 'none'
  },
  button: {
    padding: '14px',
    borderRadius: '8px',
    border: 'none',
    backgroundColor: '#0284c7',
    color: '#fff',
    fontSize: '16px',
    fontWeight: '600',
    cursor: 'pointer'
  },
  textButton: {
    background: 'none',
    border: 'none',
    color: '#0284c7',
    cursor: 'pointer',
    fontSize: '14px',
    marginTop: '8px'
  },
  error: {
    color: '#ef4444',
    backgroundColor: '#fef2f2',
    padding: '10px',
    borderRadius: '8px',
    marginBottom: '16px',
    fontSize: '14px'
  }
};

export default Login;
