// app/driver/layout.js
'use client';
import { usePathname } from 'next/navigation';
import DashboardHeader from './components/DashboardHeader';
import Sidebar from './components/Sidebar';

export default function DriverLayout({ children }) {
  const pathname = usePathname();
  
 
  const showSidebar = !pathname.includes('/logout');
  
  return (
    <div className="flex min-h-screen bg-gray-50">
      {showSidebar && <Sidebar />}
      <div className="flex-1 flex flex-col">
        <DashboardHeader />
        <main className="flex-1 p-4 md:p-6 bg-gray-50">
          {children}
        </main>
      </div>
    </div>
  );
}