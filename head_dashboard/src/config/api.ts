interface ApiConfig {
  baseUrl: string;
  endpoints: {
    auth: {
      login: string;
      logout: string;
    };
    centers: {
      list: string;
      details: string;
    };
    children: {
      list: string;
      details: string;
    };
    nutrition: {
      list: string;
      details: string;
    };
    inventory: {
      list: string;
      details: string;
    };
  };
}

const development: ApiConfig = {
  baseUrl: import.meta.env.VITE_API_BASE_URL_DEV,
  endpoints: {
    auth: {
      login: import.meta.env.VITE_AUTH_LOGIN,
      logout: import.meta.env.VITE_AUTH_LOGOUT
    },
    centers: {
      list: import.meta.env.VITE_ANGANWADI,
      details: import.meta.env.VITE_CENTERS_DETAILS
    },
    children: {
      list: import.meta.env.VITE_CHILDREN_LIST,
      details: import.meta.env.VITE_CHILDREN_DETAILS
    },
    nutrition: {
      list: import.meta.env.VITE_NUTRITION_LIST,
      details: import.meta.env.VITE_NUTRITION_DETAILS
    },
    inventory: {
      list: import.meta.env.VITE_INVENTORY_LIST,
      details: import.meta.env.VITE_INVENTORY_DETAILS
    }
  }
};

const production: ApiConfig = {
  baseUrl: import.meta.env.VITE_API_BASE_URL_PROD,
  endpoints: {
    auth: {
      login: import.meta.env.VITE_AUTH_LOGIN,
      logout: import.meta.env.VITE_AUTH_LOGOUT
    },
    centers: {
      list: import.meta.env.VITE_CENTERS_LIST,
      details: import.meta.env.VITE_CENTERS_DETAILS
    },
    children: {
      list: import.meta.env.VITE_CHILDREN_LIST,
      details: import.meta.env.VITE_CHILDREN_DETAILS
    },
    nutrition: {
      list: import.meta.env.VITE_NUTRITION_LIST,
      details: import.meta.env.VITE_NUTRITION_DETAILS
    },
    inventory: {
      list: import.meta.env.VITE_INVENTORY_LIST,
      details: import.meta.env.VITE_INVENTORY_DETAILS
    }
  }
};

const config: ApiConfig = process.env.NODE_ENV === 'production' ? production : development;

export default config;

// Export base URLs separately for direct access
export const baseUrl = config.baseUrl;
export const apiBaseUrl = config.baseUrl;