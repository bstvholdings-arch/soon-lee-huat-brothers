export type Locale = "en" | "bm" | "zh";

export type MotorcycleType = "new" | "used";
export type StockStatus = "available" | "sold";
export type AngleType = "main" | "exhaust" | "caliper" | "dashboard";
export type PartStock = "in_stock" | "low" | "out";

export type MotorcycleSpecs = {
  cc?: string;
  engine?: string;
  fuel?: string;
  notes?: string;
};

export type VehicleImage = {
  id: string;
  motorcycle_id: string;
  color_name_en: string;
  color_name_bm: string;
  color_name_zh: string;
  color_hex: string;
  image_url: string;
  is_main: boolean;
  angle_type: AngleType;
};

export type Motorcycle = {
  id: string;
  type: MotorcycleType;
  title_en: string;
  title_bm: string;
  title_zh: string;
  price: number;
  year: number | null;
  mileage: number | null;
  specs: MotorcycleSpecs;
  status: StockStatus;
  sku: string;
  stock_quantity: number;
  created_at: string;
  vehicle_images?: VehicleImage[];
};

export type Part = {
  id: string;
  name_en: string;
  name_bm: string;
  name_zh: string;
  category: string;
  applicable_model: string;
  price: number;
  image_url: string;
  stock_status: PartStock;
  sku: string;
  stock_quantity: number;
  created_at: string;
};

export type Brand = {
  id: string;
  brand_name: string;
  logo_url: string;
  display_order: number;
};

export type SiteContent = {
  id: string;
  section_key: string;
  content_en: string;
  content_bm: string;
  content_zh: string;
  images: string[];
};

export type ContentMap = Record<string, SiteContent>;
