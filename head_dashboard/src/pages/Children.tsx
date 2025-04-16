
import React, { useState, useEffect } from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import ChildrenTable from '@/components/children/ChildrenTable';
import { Search } from 'lucide-react';

const Children = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [children, setChildren] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    console.log('Fetching children data...');
    
    const fetchChildren = async () => {
      try {
        const token = localStorage.getItem('authToken');
        const response = await fetch(import.meta.env.VITE_CHILDREN_LIST, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch children data');
        }

        const data = await response.json();
        console.log('API Response:', data);
        if (Array.isArray(data.children)) {
          setChildren(data.children);
        } else {
          throw new Error('Invalid data format: children is not an array');
        }
      } catch (err) {
        console.error('Error fetching children data:', err);
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    };

    fetchChildren();
  }, []);

  const filteredChildren = children.filter(child => 
    child.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    child.center.name.toLowerCase().includes(searchTerm.toLowerCase())
  );
  

  
  if (loading) return <Layout><div>Loading...</div></Layout>;
  if (error) return <Layout><div>Error: {error}</div></Layout>;

  return (
    <Layout>
      <PageTitle 
        title="Children Registry" 
        subtitle="Track and manage children's health and nutrition"
      />
      
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
      />
    </Layout>
  );
};

export default Children;
