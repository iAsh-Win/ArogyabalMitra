import React, { useState, useEffect } from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import CenterTable, { Center } from '@/components/anganwadi/CenterTable';
import { PlusCircle, Search } from 'lucide-react';
import AddCenterModal from '@/components/anganwadi/AddCenterModal';
import { baseUrl } from '@/config/api';

const Centers = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [centers, setCenters] = useState<Center[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCenters = async () => {
      try {
        const token = localStorage.getItem('authToken');
        if (!token) {
          setError('Authentication token not found');
          return;
        }

        const response = await fetch(`${baseUrl}anganwadi/all`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });

        if (!response.ok) {
          throw new Error('Failed to fetch centers');
        }

        const data = await response.json();
        console.log('API Response:', data);

        if (!data || typeof data !== 'object' || !Array.isArray(data.anganwadi_users)) {
          console.warn('Unexpected data format:', data);
          setCenters([]);
          throw new Error('Invalid data format: Expected an array of centers');
        }

        const transformedCenters = data.anganwadi_users.map(center => ({
          center_name: center.center_name || 'N/A',
          state: center.state || 'Unknown',
          full_name: center.full_name || 'No Supervisor',
          status: center.is_active ? 'Active' : 'Inactive',
          email: center.email || 'N/A',
          phone_number: center.phone_number || 'N/A',
          village: center.village || 'N/A',
          district: center.district || 'N/A',
          pin_code: center.pin_code || 'N/A'
        }));
        setCenters(transformedCenters);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch centers');
      } finally {
        setIsLoading(false);
      }
    };

    fetchCenters();
  }, []);
  
  const filteredCenters = centers.filter(center => 
    (center.center_name && center.center_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (center.full_name && center.full_name.toLowerCase().includes(searchTerm.toLowerCase())) ||
    (center.state && center.state.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const handleAddSuccess = () => {
    setIsAddModalOpen(false);
    const token = localStorage.getItem('authToken');
    if (token) {
      fetch(`${baseUrl}anganwadi/all`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
        .then(response => response.json())
        .then(data => {
          if (data && typeof data === 'object' && Array.isArray(data.anganwadi_users)) {
            const transformedCenters = data.anganwadi_users.map(center => ({
              center_name: center.center_name || 'N/A',
              state: center.state || 'Unknown',
              full_name: center.full_name || 'No Supervisor',
              status: center.is_active ? 'Active' : 'Inactive',
              email: center.email || 'N/A',
              phone_number: center.phone_number || 'N/A',
              village: center.village || 'N/A',
              district: center.district || 'N/A',
              pin_code: center.pin_code || 'N/A'
            }));
            setCenters(transformedCenters);
          } else {
            console.warn('Unexpected data format during refresh:', data);
            setCenters([]);
          }
        })
        .catch(err => console.error('Error refreshing centers:', err));
    }
  };
  
  if (isLoading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-full">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <div className="text-red-500 text-center">{error}</div>
      </Layout>
    );
  }
  
  return (
    <Layout>
      <PageTitle 
        title="Anganwadi Centers" 
        subtitle="Manage and monitor all centers in your region"
      >
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="bg-primary text-primary-foreground rounded-md px-4 py-2 text-sm font-medium flex items-center hover:bg-primary/90 transition-colors"
        >
          <PlusCircle size={16} className="mr-2" />
          Add Center
        </button>
      </PageTitle>
      
      <div className="mb-6">
        <div className="relative">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Search className="h-4 w-4 text-muted-foreground" />
          </div>
          <input
            type="text"
            placeholder="Search centers..."
            className="pl-10 pr-4 py-2 w-full border rounded-md text-sm focus:ring-1 focus:ring-primary input-focus"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>
      
      <CenterTable 
        centers={filteredCenters} 
      />

      <AddCenterModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onSuccess={handleAddSuccess}
      />
    </Layout>
  );
};

export default Centers;