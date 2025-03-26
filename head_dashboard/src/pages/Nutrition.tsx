import React from 'react';
import Layout from '@/components/layout/Layout';
import PageTitle from '@/components/common/PageTitle';
import NutritionMap from '@/components/dashboard/NutritionMap';
import { MapLocation } from '@/components/dashboard/NutritionMap';

const Nutrition: React.FC = () => {
  // Dummy data for the nutrition map
  const hotspots: MapLocation[] = [
    { id: 1, name: 'North District', severity: 'severe', x: 25, y: 35, count: 32 },
    { id: 2, name: 'East Village', severity: 'moderate', x: 65, y: 45, count: 18 },
    { id: 3, name: 'South Center', severity: 'mild', x: 40, y: 70, count: 12 },
    { id: 4, name: 'West Region', severity: 'healthy', x: 15, y: 60, count: 5 },
    { id: 5, name: 'Central Area', severity: 'moderate', x: 50, y: 50, count: 22 },
    { id: 6, name: 'Hill Station', severity: 'severe', x: 80, y: 20, count: 28 },
    { id: 7, name: 'River Town', severity: 'mild', x: 35, y: 25, count: 14 },
    { id: 8, name: 'Forest Edge', severity: 'healthy', x: 70, y: 75, count: 7 }
  ];

  return (
    <Layout>
      <PageTitle title="Nutrition Overview" subtitle="Insights into regional nutrition status" />
      <NutritionMap locations={hotspots} />
    </Layout>
  );
};

export default Nutrition;
