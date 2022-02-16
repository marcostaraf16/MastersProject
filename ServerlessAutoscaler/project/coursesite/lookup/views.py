from django.views import generic
from django.shortcuts import render
from .models import Course

class IndexView(generic.ListView):
   template_name = 'lookup/index.html'
   context_object_name = 'all_courses'

   def get_queryset(self):
       return Course.objects.all()

class DetailView(generic.DetailView):
    model = Course
    template_name = 'lookup/detail.html'
