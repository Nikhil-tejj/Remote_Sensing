const express = require('express');
const app = express();
const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/bookdb', { useNewUrlParser: true,
useUnifiedTopology: true });

// Define the Book schema
const bookSchema = new mongoose.Schema({
  title: { type: String, required: true },
  author: { type: String, required: true },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [1, 'Quantity must be at least 1']
  }
});

// Define the Book model
const Book = mongoose.model('Book', bookSchema);

// Create a new book
app.post('/api/books', (req, res) => {
  const book = new Book(req.body);
  book.save((err, savedBook) => {
    if (err) {
      res.status(500).json({ message: err.message });
    } else {
      res.status(201).json(savedBook);
    }
  });
});

// Get all books
app.get('/api/books', (req, res) => {
  Book.find((err, books) => {
    if (err) {
      res.status(500).json({ message: err.message });
    } else {
      res.status(200).json(books);
    }
  });
});

// Get a specific book by ID
app.get('/api/books/:id', (req, res) => {
  Book.findById(req.params.id, (err, book) => {
    if (!book) {
      res.status(404).json({ message: 'Book not found' });
    } else if (err) {
      res.status(500).json({ message: err.message });
    } else {
      res.status(200).json(book);
    }
  });
});

// Update a book by ID
app.put('/api/books/:id', (req, res) => {
  Book.findByIdAndUpdate(req.params.id, req.body, { new: true }, (err,
updatedBook) => {
    if (!updatedBook) {
      res.status(404).json({ message: 'Book not found' });
    } else if (err) {
      res.status(500).json({ message: err.message });
    } else {
      res.status(200).json(updatedBook);
    }
  });
});

// Delete a book by ID
app.delete('/api/books/:id', (req, res) => {
  Book.findByIdAndRemove(req.params.id, (err, deletedBook) => {
    if (!deletedBook) {
      res.status(404).json({ message: 'Book not found' });
    } else if (err) {
      res.status(500).json({ message: err.message });
    } else {
      res.status(200).json({ message: 'Book deleted successfully' });
    }
  });
});

app.listen(3000, () => {
  console.log('Server started on port 3000');
});