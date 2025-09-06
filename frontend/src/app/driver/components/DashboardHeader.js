
'use client';
import { useAuth } from '@/hooks/useAuth';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const DashboardHeader = () => {
  const { user } = useAuth();
  
  return (
    <header className="bg-white shadow-md">
      <div className="px-4 py-3 md:px-6 md:py-4 flex items-center justify-between">
     
        <div className="flex items-center space-x-4 md:space-x-10">
          <Link href="/driver/dashboard" className="flex items-center space-x-2">
            <div className="bg-blue-600 w-8 h-8 md:w-10 md:h-10 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-lg md:text-xl">DE</span>
            </div>
            <span className="font-bold text-lg md:text-xl text-blue-800">DriveExpress</span>
          </Link>
          
          <div className="hidden lg:block flex-1 max-w-md">
            <div className="relative">
              <input
                type="text"
                placeholder="Search orders, locations..."
                className="w-full pl-4 pr-10 py-2 rounded-full border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <svg 
                className="absolute right-3 top-2.5 h-5 w-5 text-gray-400" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>
        </div>
        
        {/* Profile Section */}
        <div className="flex items-center space-x-3">
          <div className="hidden md:block text-right">
            <p className="font-medium">{user?.name}</p>
            <p className="text-xs text-gray-500">Driver ID: D-7894</p>
          </div>
          <div className="relative">
            <div className="bg-gray-200 border-2 border-dashed rounded-xl w-10 h-10 md:w-12 md:h-12" />
            <span className="absolute bottom-0 right-0 bg-green-500 border-2 border-white rounded-full w-3 h-3"></span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default DashboardHeader;