import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import { User, Calendar, MapPin, Activity, Scale, Ruler } from 'lucide-react';

interface ChildDetails {
  personal_info: {
    id: string;
    name: string;
    gender: string;
    birth_date: string;
    age: {
      years: number;
      months: number;
    };
    aadhaar_number: string;
  };
  address: {
    village: string;
    society_name: string;
    district: string;
    state: string;
    pin_code: string;
  };
  parent_info: {
    father_name: string;
    father_contact: string;
    mother_name: string;
    parent_aadhaar_number: string;
  };
  anganwadi_info: {
    center_name: string;
    center_code: string;
    worker_name: string;
    worker_contact: string;
  };
  health_info: {
    malnutrition_status: string;
    latest_record: {
      weight: number;
      height: number;
      muac: number;
      waz: number;
      haz: number;
      whz: number;
      recommended_supplements: Array<{
        name: string;
        is_distributed: boolean;
        quantity_distributed: number;
        distribution_date: string;
      }>;
      nutrient_deficiencies: string[];
      record_date: string;
    };
  };
}

const ChildDetails = () => {
  const { id } = useParams<{ id: string }>();
  const [child, setChild] = useState<ChildDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchChildDetails = async () => {
      try {
        const token = localStorage.getItem('authToken');
        const response = await fetch(`${import.meta.env.VITE_CHILDREN_DETAILS}/${id}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch child details');
        }

        const data = await response.json();
        console.log('Child details:', data);
        setChild(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchChildDetails();
    }
  }, [id]);

  if (loading) return <Layout><div>Loading...</div></Layout>;
  if (error) return <Layout><div>Error: {error}</div></Layout>;
  if (!child) return <Layout><div>Child not found</div></Layout>;

  return (
    <Layout>
      <PageTitle 
        title={child.personal_info.name}
        subtitle="Child Details"
      />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-card rounded-lg border p-6 shadow-sm">
          <h2 className="text-lg font-semibold mb-4">Personal Information</h2>
          <div className="space-y-4">
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Name:</span>
              <span className="ml-2 font-medium">{child.personal_info.name}</span>
            </div>
            <div className="flex items-center">
              <Calendar className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Age:</span>
              <span className="ml-2">{child.personal_info.age.years} years {child.personal_info.age.months} months</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Gender:</span>
              <span className="ml-2">{child.personal_info.gender}</span>
            </div>
            <div className="flex items-center">
              <Calendar className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Birth Date:</span>
              <span className="ml-2">{new Date(child.personal_info.birth_date).toLocaleDateString()}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Aadhaar:</span>
              <span className="ml-2">{child.personal_info.aadhaar_number}</span>
            </div>
          </div>
        </div>

        <div className="bg-card rounded-lg border p-6 shadow-sm">
          <h2 className="text-lg font-semibold mb-4">Address Information</h2>
          <div className="space-y-4">
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Village:</span>
              <span className="ml-2">{child.address.village}</span>
            </div>
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Society:</span>
              <span className="ml-2">{child.address.society_name}</span>
            </div>
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">District:</span>
              <span className="ml-2">{child.address.district}</span>
            </div>
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">State:</span>
              <span className="ml-2">{child.address.state}</span>
            </div>
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">PIN Code:</span>
              <span className="ml-2">{child.address.pin_code}</span>
            </div>
          </div>
        </div>

        <div className="bg-card rounded-lg border p-6 shadow-sm">
          <h2 className="text-lg font-semibold mb-4">Family Information</h2>
          <div className="space-y-4">
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Father's Name:</span>
              <span className="ml-2">{child.parent_info.father_name}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Father's Contact:</span>
              <span className="ml-2">{child.parent_info.father_contact}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Mother's Name:</span>
              <span className="ml-2">{child.parent_info.mother_name}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Parent's Aadhaar:</span>
              <span className="ml-2">{child.parent_info.parent_aadhaar_number}</span>
            </div>
          </div>
        </div>

        <div className="bg-card rounded-lg border p-6 shadow-sm">
          <h2 className="text-lg font-semibold mb-4">Anganwadi Information</h2>
          <div className="space-y-4">
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Center Name:</span>
              <span className="ml-2">{child.anganwadi_info.center_name}</span>
            </div>
            <div className="flex items-center">
              <MapPin className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Center Code:</span>
              <span className="ml-2">{child.anganwadi_info.center_code}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Worker Name:</span>
              <span className="ml-2">{child.anganwadi_info.worker_name}</span>
            </div>
            <div className="flex items-center">
              <User className="h-5 w-5 mr-2 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">Worker Contact:</span>
              <span className="ml-2">{child.anganwadi_info.worker_contact}</span>
            </div>
          </div>
        </div>

        <div className="bg-card rounded-lg border p-6 shadow-sm md:col-span-2">
          <h2 className="text-lg font-semibold mb-4">Health Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <div className="flex items-center">
                <Activity className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">Malnutrition Status:</span>
                <span className="ml-2">{child.health_info.malnutrition_status}</span>
              </div>
              <div className="flex items-center">
                <Scale className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">Weight:</span>
                <span className="ml-2">{child.health_info.latest_record.weight} kg</span>
              </div>
              <div className="flex items-center">
                <Ruler className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">Height:</span>
                <span className="ml-2">{child.health_info.latest_record.height} cm</span>
              </div>
              <div className="flex items-center">
                <Ruler className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">MUAC:</span>
                <span className="ml-2">{child.health_info.latest_record.muac} cm</span>
              </div>
            </div>
            <div className="space-y-4">
              <div className="flex items-center">
                <Activity className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">WAZ Score:</span>
                <span className="ml-2">{child.health_info.latest_record.waz.toFixed(2)}</span>
              </div>
              <div className="flex items-center">
                <Activity className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">HAZ Score:</span>
                <span className="ml-2">{child.health_info.latest_record.haz.toFixed(2)}</span>
              </div>
              <div className="flex items-center">
                <Activity className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">WHZ Score:</span>
                <span className="ml-2">{child.health_info.latest_record.whz.toFixed(2)}</span>
              </div>
              <div className="flex items-center">
                <Calendar className="h-5 w-5 mr-2 text-muted-foreground" />
                <span className="text-sm text-muted-foreground">Record Date:</span>
                <span className="ml-2">{new Date(child.health_info.latest_record.record_date).toLocaleDateString()}</span>
              </div>
            </div>
          </div>

          <div className="mt-6">
            <h3 className="text-md font-semibold mb-3">Nutrient Deficiencies</h3>
            <div className="flex flex-wrap gap-2">
              {child.health_info.latest_record.nutrient_deficiencies.map((deficiency, index) => (
                <span key={index} className="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm">
                  {deficiency}
                </span>
              ))}
            </div>
          </div>

          <div className="mt-6">
            <h3 className="text-md font-semibold mb-3">Recommended Supplements</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {child.health_info.latest_record.recommended_supplements.map((supplement, index) => (
                <div key={index} className="flex items-center space-x-2 bg-green-50 p-3 rounded-md">
                  <div className={`w-2 h-2 rounded-full ${supplement.is_distributed ? 'bg-green-500' : 'bg-yellow-500'}`} />
                  <div>
                    <div className="font-medium">{supplement.name}</div>
                    <div className="text-sm text-muted-foreground">
                      {supplement.is_distributed ? `Distributed: ${supplement.quantity_distributed} units` : 'Not distributed'}
                    </div>
                    {supplement.is_distributed && (
                      <div className="text-xs text-muted-foreground">
                        {new Date(supplement.distribution_date).toLocaleDateString()}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default ChildDetails;