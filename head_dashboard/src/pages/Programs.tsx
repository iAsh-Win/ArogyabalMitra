import React, { useState, useEffect } from 'react';
import Layout from '@/components/layout/Layout';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { useToast } from '@/components/ui/use-toast';
import { baseUrl } from '@/config/api';

interface Program {
  id: string;
  title: string;
  description: string;
  date: string;
}

const Programs = () => {
  const [programs, setPrograms] = useState<Program[]>([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [date, setDate] = useState('');
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const fetchPrograms = async () => {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) {
        toast({
          variant: 'destructive',
          title: 'Error',
          description: 'Authentication token not found',
        });
        return;
      }

      const response = await fetch(`${baseUrl}head_officer/programs`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Failed to fetch programs');
      }

      const data = await response.json();
      setPrograms(data.programs || []);
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: error instanceof Error ? error.message : 'Failed to fetch programs',
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const token = localStorage.getItem('authToken');
      if (!token) {
        toast({
          variant: 'destructive',
          title: 'Error',
          description: 'Authentication token not found',
        });
        return;
      }

      const response = await fetch(`${baseUrl}head_officer/programs/create`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ title, description, date })
      });

      if (!response.ok) {
        throw new Error('Failed to create program');
      }

      toast({
        title: 'Success',
        description: 'Program created successfully',
      });

      setTitle('');
      setDescription('');
      setDate('');
      fetchPrograms();
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: error instanceof Error ? error.message : 'Failed to create program',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (programId: string) => {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) {
        toast({
          variant: 'destructive',
          title: 'Error',
          description: 'Authentication token not found',
        });
        return;
      }

      const response = await fetch(`${baseUrl}head_officer/programs/delete/${programId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error('Failed to delete program');
      }

      toast({
        title: 'Success',
        description: 'Program deleted successfully',
      });

      fetchPrograms();
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: error instanceof Error ? error.message : 'Failed to delete program',
      });
    }
  };

  useEffect(() => {
    fetchPrograms();
  }, []);

  return (
    <Layout>
      <div className="space-y-8">
        <div className="bg-card rounded-lg p-6 shadow-sm">
          <h2 className="text-2xl font-semibold mb-6">Create New Program</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="title" className="block text-sm font-medium mb-1">Title</label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
              />
            </div>
            <div>
              <label htmlFor="description" className="block text-sm font-medium mb-1">Description</label>
              <Textarea
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                required
              />
            </div>
            <div>
              <label htmlFor="date" className="block text-sm font-medium mb-1">Date</label>
              <Input
                id="date"
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                required
              />
            </div>
            <Button type="submit" disabled={loading}>
              {loading ? 'Creating...' : 'Create Program'}
            </Button>
          </form>
        </div>

        <div className="bg-card rounded-lg p-6 shadow-sm">
          <h2 className="text-2xl font-semibold mb-6">Programs List</h2>
          <div className="space-y-4">
            {programs.map((program) => (
              <div key={program.id} className="border rounded-lg p-4">
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="text-lg font-medium">{program.title}</h3>
                    <p className="text-muted-foreground mt-1">{program.description}</p>
                    <p className="text-sm text-muted-foreground mt-2">{new Date(program.date).toLocaleDateString()}</p>
                  </div>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={() => handleDelete(program.id)}
                  >
                    Delete
                  </Button>
                </div>
              </div>
            ))}
            {programs.length === 0 && (
              <p className="text-muted-foreground text-center py-4">No programs found</p>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Programs;