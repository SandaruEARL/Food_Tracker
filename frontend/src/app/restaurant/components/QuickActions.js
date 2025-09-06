'use client';
import { useState } from 'react';

const QuickActions = () => {
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    image: null
  });
  const [previewImage, setPreviewImage] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData(prev => ({ ...prev, image: file }));
      setPreviewImage(URL.createObjectURL(file));
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    console.log('Menu item submitted:', formData);
    alert('Menu item added successfully!');
    resetForm();
    setShowModal(false);
  };

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      price: '',
      category: '',
      image: null
    });
    setPreviewImage(null);
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-md mt-6">
      <h2 className="text-xl font-bold mb-4">Quick Actions</h2>
      <div className="flex flex-wrap gap-3">
        <button 
          onClick={() => setShowModal(true)}
          className="flex items-center bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md"
        >
          <span className="mr-2">+</span> Add New Menu Item
        </button>
        <button className="flex items-center bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-md">
          <span className="mr-2">📋</span> View All Orders History
        </button>
        <button className="flex items-center bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded-md">
          <span className="mr-2">🔄</span> Refresh Orders
        </button>
      </div>

      {/* Add Menu Item Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
            <div className="flex justify-between items-center p-4 border-b">
              <h3 className="text-xl font-bold">Add New Menu Item</h3>
              <button 
                onClick={() => {
                  setShowModal(false);
                  resetForm();
                }}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-4">
              <div className="space-y-4">
                {/* Item Name */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Item Name *
                  </label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    required
                    className="w-full p-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., Margherita Pizza"
                  />
                </div>
                
                {/* Description */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Description
                  </label>
                  <textarea
                    name="description"
                    value={formData.description}
                    onChange={handleChange}
                    rows="3"
                    className="w-full p-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Describe the item..."
                  ></textarea>
                </div>
                
                {/* Price */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Price *
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500">
                      Rs.
                    </span>
                    <input
                      type="number"
                      name="price"
                      value={formData.price}
                      onChange={handleChange}
                      required
                      min="0"
                      step="0.01"
                      className="w-full pl-8 p-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                      placeholder="0.00"
                    />
                  </div>
                </div>
                
                {/* Category */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Category *
                  </label>
                  <select
                    name="category"
                    value={formData.category}
                    onChange={handleChange}
                    required
                    className="w-full p-2 border rounded-md focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="">Select a category</option>
                    <option value="Appetizers">Appetizers</option>
                    <option value="Main Courses">Main Courses</option>
                    <option value="Desserts">Desserts</option>
                    <option value="Drinks">Drinks</option>
                    <option value="Sides">Sides</option>
                  </select>
                </div>
                
                {/* Image Upload */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Item Image
                  </label>
                  <div className="flex items-center space-x-4">
                    <div className="relative">
                      {previewImage ? (
                        <img 
                          src={previewImage} 
                          alt="Preview" 
                          className="w-16 h-16 object-cover rounded-md border"
                        />
                      ) : (
                        <div className="bg-gray-200 border-2 border-dashed rounded-md w-16 h-16 flex items-center justify-center">
                          <span className="text-gray-500 text-2xl">+</span>
                        </div>
                      )}
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      />
                    </div>
                    <div>
                      <p className="text-sm text-gray-500">
                        Upload a photo of your item
                      </p>
                      <p className="text-xs text-gray-400">
                        JPG, PNG (max 2MB)
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="mt-6 flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false);
                    resetForm();
                  }}
                  className="px-4 py-2 border rounded-md hover:bg-gray-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
                >
                  Add Menu Item
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default QuickActions;