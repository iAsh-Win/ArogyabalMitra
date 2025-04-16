
// Import the correct MapLocation type
import { MapLocation } from '@/components/dashboard/NutritionMap';
import Layout from "@/components/layout/Layout";
import PageTitle from "@/components/common/PageTitle";
import DashboardCard from "@/components/dashboard/DashboardCard";
import { Button } from "@/components/ui/button";
import { Plus as PlusIcon } from "lucide-react"; // Changed from @radix-ui/react-icons to lucide-react
import { Calendar } from "@/components/ui/calendar";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { addDays, format } from "date-fns";
import { CalendarIcon } from "lucide-react";
import { useState, useEffect } from "react";
import { Progress } from "@/components/ui/progress";
import NutritionMap from "@/components/dashboard/NutritionMap";

interface NutritionStats {
  total_children: number;
  malnutrition_summary: {
    total_malnutrition: number;
    no_malnutrition: number;
    severe_cases: number;
    moderate_cases: number;
  };
  hotspots: {
    severe: Array<{
      location: string;
      district: string;
      state: string;
      pin_code: string;
      center_name: string;
      center_code: string;
      count: number;
      child: {
        name: string;
        gender: string;
        birth_date: string;
        aadhaar_number: string;
        father_name: string;
        mother_name: string;
      };
      metrics: {
        waz: number;
        haz: number;
        whz: number;
        muac: number;
      };
    }>;
    moderate: Array<{
      location: string;
      district: string;
      state: string;
      pin_code: string;
      center_name: string;
      center_code: string;
      count: number;
      child: {
        id:string
        name: string;
        gender: string;
        birth_date: string;
        aadhaar_number: string;
        father_name: string;
        mother_name: string;
      };
      metrics: {
        waz: number;
        haz: number;
        whz: number;
        muac: number;
      };
    }>;
  };
}

const Index = () => {
  const [stats, setStats] = useState<NutritionStats | null>(null);
  const [hotspots, setHotspots] = useState<MapLocation[]>([]);

  useEffect(() => {
    const fetchNutritionStats = async () => {
      try {
        const authToken = localStorage.getItem('authToken');
        const response = await fetch(import.meta.env.VITE_STATES_DETAILS, {
          headers: {
            'Authorization': `Bearer ${authToken}`,
            'Content-Type': 'application/json'
          }
        });
        const data = await response.json();
        setStats(data);

        // Transform hotspots data
        if (data.hotspots) {
          const locations: MapLocation[] = [
            ...(data.hotspots.severe || []).map((spot: any) => ({
              child_id: spot.child.aadhaar_number,
              pin_code: spot.pin_code,
              village: spot.location,
              district: spot.district,
              severity: 'severe' as const
            })),
            ...(data.hotspots.moderate || []).map((spot: any) => ({
              child_id: spot.child.aadhaar_number,
              pin_code: spot.pin_code,
              village: spot.location,
              district: spot.district,
              severity: 'moderate' as const
            }))
          ];
          setHotspots(locations);
        }
      } catch (error) {
        console.error('Error fetching nutrition stats:', error);
      }
    };

    fetchNutritionStats();
  }, []);


  return (
    <Layout>
      <PageTitle title="Dashboard" subtitle="Overview of key metrics and insights">
      </PageTitle>

      <div className="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
        <DashboardCard title="Total Children" subtitle="As of today">
          <div className="text-3xl font-bold">{stats?.total_children || 0}</div>
        </DashboardCard>

        <DashboardCard title="Severely Malnourished" subtitle="Children needing immediate attention">
          <div className="text-3xl font-bold text-anganwadi-severe">{stats?.malnutrition_summary.severe_cases || 0}</div>
        </DashboardCard>

        <DashboardCard title="Moderate Cases" subtitle="Children requiring close monitoring">
          <div className="text-3xl font-bold text-anganwadi-moderate">{stats?.malnutrition_summary.moderate_cases || 0}</div>
        </DashboardCard>

        <DashboardCard title="Healthy Children" subtitle="Children with normal nutrition levels">
          <div className="text-3xl font-bold text-anganwadi-healthy">{stats?.malnutrition_summary.no_malnutrition || 0}</div>
        </DashboardCard>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mt-6">
        <DashboardCard title="Nutrition Levels Overview" subtitle="Current progress across all children">
          <div className="space-y-3">
            <div className="space-y-1">
              <p className="text-sm font-medium">Severe</p>
              <Progress value={(stats?.malnutrition_summary.severe_cases || 0) / (stats?.total_children || 1) * 100} color="bg-anganwadi-severe" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">Moderate</p>
              <Progress value={(stats?.malnutrition_summary.moderate_cases || 0) / (stats?.total_children || 1) * 100} color="bg-anganwadi-moderate" />
            </div>
            <div className="space-y-1">
              <p className="text-sm font-medium">Healthy</p>
              <Progress value={(stats?.malnutrition_summary.no_malnutrition || 0) / (stats?.total_children || 1) * 100} color="bg-anganwadi-healthy" />
            </div>
          </div>
        </DashboardCard>

        <NutritionMap locations={hotspots} />
      </div>

      <div className="mt-6">
        <DashboardCard title="Children Details" subtitle="List of children with nutrition status">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted text-muted-foreground text-left">
                <tr>
                  <th className="px-4 py-3 font-medium">Name</th>
                  <th className="px-4 py-3 font-medium">Gender</th>
                  <th className="px-4 py-3 font-medium">Birth Date</th>
                  <th className="px-4 py-3 font-medium">Center Name</th>
                  <th className="px-4 py-3 font-medium">Center Code</th>
                  <th className="px-4 py-3 font-medium">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {[...(stats?.hotspots.severe || []), ...(stats?.hotspots.moderate || [])].map((spot, index) => (
                  <tr
                    key={index}
                    className="hover:bg-muted/50 transition-colors cursor-pointer"
                    onClick={() => {
                      const childId = spot.child.id;
                      window.location.href = `/children/child/${childId}`;
                    }}
                  >
                    <td className="px-4 py-3 font-medium">{spot.child.name}</td>
                    <td className="px-4 py-3 text-muted-foreground">{spot.child.gender}</td>
                    <td className="px-4 py-3 text-muted-foreground">{spot.child.birth_date}</td>
                    <td className="px-4 py-3 text-muted-foreground">{spot.center_name}</td>
                    <td className="px-4 py-3 text-muted-foreground">{spot.center_code}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${spot.severity === 'severe' ? 'bg-red-100 text-red-800' : 'bg-yellow-100 text-yellow-800'}`}>
                          {spot.severity === 'severe' ? 'Severe' : 'Moderate'}
                        </span>
                        {spot.severity === 'severe' && (
                          <span className="flex h-2 w-2 relative">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                            <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500"></span>
                          </span>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </DashboardCard>
      </div>
    </Layout>
  );
};

export default Index;
