import React, { useEffect, useState } from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import NutritionMap from '@/components/dashboard/NutritionMap';
import { MapLocation } from '@/components/dashboard/NutritionMap';

const Nutrition: React.FC = () => {
  const [hotspots, setHotspots] = useState<MapLocation[]>([]);

  useEffect(() => {
    const fetchHotspots = async () => {
      try {
        const response = await fetch(import.meta.env.VITE_STATES_DETAILS);
        const data = await response.json();
        
        // Transform severe and moderate cases into MapLocation array
        const locations: MapLocation[] = [
          ...data.malnutrition_hotspots.severe.map((spot: any) => ({
            ...spot,
            severity: 'severe' as const
          })),
          ...data.malnutrition_hotspots.moderate.map((spot: any) => ({
            ...spot,
            severity: 'moderate' as const
          }))
        ];

        setHotspots(locations);
      } catch (error) {
        console.error('Error fetching hotspots:', error);
      }
    };

    fetchHotspots();
  }, []);

  return (
    <Layout>
      <PageTitle title="Nutrition Overview" subtitle="Insights into regional nutrition status" />
      <NutritionMap locations={hotspots} />
    </Layout>
  );
};

export default Nutrition;
