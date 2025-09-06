'use client';
import '../app/globals.css';
import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';

const LoginForm = () => {
  const router = useRouter();
  const { login, register } = useAuth();
  const [isRegistering, setIsRegistering] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [type, setType] = useState('CUSTOMER');
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
  
    try {
      if (isRegistering) {
        await register({ name, email, password, type });
      
      } else {
        await login({ email, password });
  
      }
    } catch (err) {
      setError('Something went wrong. Please check your input.');
    }
  };
  

  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto border rounded-xl p-10 mt-10">
      <h2 className="text-xl font-bold mb-4">{isRegistering ? 'Register' : 'Login'}</h2>

      {error && <p className="text-red-600 mb-2">{error}</p>}

      {isRegistering && (
        <>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder={type === 'RESTAURANT' ? 'Restaurant Name' : 'Full Name'}
            className="border p-2 w-full mb-2 rounded-xl"
            required
          />
          <select
            value={type}
            onChange={(e) => setType(e.target.value)}
            className="border p-2 w-full mb-2 rounded-xl"
          >
            <option value="CUSTOMER">Customer</option>
            <option value="DRIVER">Driver</option>
            <option value="RESTAURANT">Restaurant</option>
          </select>
        </>
      )}

      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        className="border p-2 w-full mb-2 rounded-xl"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        className="border p-2 w-full mb-4 rounded-xl"
        required
      />

      <button
        type="submit"
        className="bg-blue-600 text-white px-4 py-2 rounded-xl w-full mb-2"
      >
        {isRegistering ? 'Register' : 'Login'}
      </button>

      <button
        type="button"
        onClick={() => setIsRegistering(!isRegistering)}
        className="text-sm text-blue-600 underline w-full rounded-xl"
      >
        {isRegistering ? 'Already have an account? Login' : "Don't have an account? Register"}
      </button>
    </form>
  );
};

export default LoginForm;