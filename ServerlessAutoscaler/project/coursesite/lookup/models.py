from django.db import models
from django.utils import timezone
from django.contrib import admin
import datetime

# Create your models here.
class Course(models.Model):
    course_name = models.CharField(max_length=20)
    professor = models.CharField(max_length=50)
    days = models.CharField(max_length=5)
    class_size = models.IntegerField()
