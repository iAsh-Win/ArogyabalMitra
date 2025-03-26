
import React, { useState } from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import ChildrenTable, { Child } from '@/components/children/ChildrenTable';
import { PlusCircle, Search, Filter } from 'lucide-react';

// Mock data
const childrenData: Child[] = [
  {
    id: 1,
    name: 'Arjun Sharma',
    age: '3 yrs',
    gender: 'male',
    center: 'Anganwadi Center 1',
    nutritionalStatus: 'healthy',
    lastCheckup: '3 days ago',
    vaccinations: 9
  },
  {
    id: 2,
    name: 'Riya Patel',
    age: '2 yrs',
    gender: 'female',
    center: 'Anganwadi Center 2',
    nutritionalStatus: 'mild',
    lastCheckup: '1 week ago',
    vaccinations: 7
  },
  {
    id: 3,
    name: 'Aditya Kumar',
    age: '4 yrs',
    gender: 'male',
    center: 'Anganwadi Center 1',
    nutritionalStatus: 'moderate',
    lastCheckup: '2 weeks ago',
    vaccinations: 8
  },
  {
    id: 4,
    name: 'Ananya Singh',
    age: '1 yr',
    gender: 'female',
    center: 'Anganwadi Center 3',
    nutritionalStatus: 'severe',
    lastCheckup: '2 days ago',
    vaccinations: 5
  },
  {
    id: 5,
    name: 'Rohan Gupta',
    age: '5 yrs',
    gender: 'male',
    center: 'Anganwadi Center 2',
    nutritionalStatus: 'healthy',
    lastCheckup: '1 month ago',
    vaccinations: 10
  },
];

const Children = () => {
  const [searchTerm, setSearchTerm] = useState('');
  
  const filteredChildren = childrenData.filter(child => 
    child.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    child.center.toLowerCase().includes(searchTerm.toLowerCase())
  );
  
  const handleViewDetails = (child: Child) => {
    console.log('View details for child:', child);
    // In a real application, this would open a modal or navigate to a detail page
  };
  
  return (
    <Layout>
      <PageTitle 
        title="Children Registry" 
        subtitle="Track and manage children's health and nutrition"
      >
      </PageTitle>
      
      <div className="mb-6 flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Search className="h-4 w-4 text-muted-foreground" />
          </div>
          <input
            type="text"
            placeholder="Search children..."
            className="pl-10 pr-4 py-2 w-full border rounded-md text-sm focus:ring-1 focus:ring-primary input-focus"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>
      
      <ChildrenTable 
        children={filteredChildren} 
        onViewDetails={handleViewDetails}
      />
    </Layout>
  );
};

export default Children;
