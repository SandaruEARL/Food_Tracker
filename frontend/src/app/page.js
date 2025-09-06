"use client";

import LoginForm from '@/components/LoginForm';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { useEffect, useState } from 'react';

export default function Home() {
  const router = useRouter();
  const { user, loading } = useAuth();
  const [isRedirecting, setIsRedirecting] = useState(false);

  console.log("User:", user);

  useEffect(() => {
    if (!loading && user) {
     
      const userType = user.type.toLowerCase();
      if (userType?.toUpperCase() === "DRIVER") {
        router.replace("/driver/dashboard");
      } else if (userType?.toUpperCase() === "CUSTOMER") {
        router.replace("/customer");
      }else if(userType?.toUpperCase() === "RESTAURANT") {
        router.replace("/restaurant");
      } else {
        router.replace("/");
      }
    }
  }, [user, loading, router]);

  if (loading) return <p>Loading user info...</p>;

  if (isRedirecting) return <p>Redirecting...</p>;

  if (!user) return <LoginForm />;

  return null;
}
