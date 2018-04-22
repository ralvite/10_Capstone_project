# 1.When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd
# 
# and i woud:
# sleep
# eat
# give
# * die
# 
# 2.Guy at my table's wife got up to go to the bathroom and 
# I asked about dessert and he started telling me about his
# 
# *x financial
# spiritual
# horticultural
# * marital
# 
# > getProbabilityFrom3Gram("about his financial")
# [1] 0.0003603596
# > getProbabilityFrom3Gram("about his spiritual")
# [1] 1.199235e-05
# > getProbabilityFrom3Gram("about his horticultural")
# [1] 1.036838e-06
# > getProbabilityFrom3Gram("about his marital")
# [1] 2.980909e-06

# 3. Question 3
# I'd give anything to see arctic monkeys this
# decade
# month
# morning
# * weekend
# 
# Error in getProbabilityFrom3Gram("monkeys this decade") : 
#   [monkeys this] not found in the 3-gram model.

# 4.Talking to your mom has the same effect as a hug and helps reduce your
# * stress
# happiness
# hunger
# sleepiness

# > getProbabilityFrom3Gram("helps reduce stress")
# [1] 0.01019814
# > getProbabilityFrom3Gram("helps reduce happiness")
# [1] 6.574132e-05
# > getProbabilityFrom3Gram("helps reduce hunger")
# [1] 5.457168e-05
# > getProbabilityFrom3Gram("helps reduce sleepiness")
# [1] 1.116964e-06

# 5. Question 5
# When you were in Holland you were like 1 inch away from me but you hadn't time to take a
# picture
# * xlook
# minute
# * walk

# > getProbabilityFrom3Gram("time take picture")
# [1] 0.0002391899
# > getProbabilityFrom3Gram("time take look")
# [1] 0.001014522
# > getProbabilityFrom3Gram("time take minute")
# [1] 0.0001439288
# > getProbabilityFrom3Gram("time take walk")
# [1] 0.0002679118

# 6. Question 6
# I'd just like all of these questions answered, a presentation of evidence, 
# and a jury to settle the
# *x case
# account
# matter
# incident

# > getProbabilityFrom3Gram("jury settle case")
# Error in getProbabilityFrom3Gram("jury settle case") : 
#     [jury settle] not found in the 3-gram model.

# > getProbabilityFrom3Gram("settle the case")
# [1] 0.06988659
# > getProbabilityFrom3Gram("settle the account")
# [1] 6.596276e-05
# > getProbabilityFrom3Gram("settle the matter")
# [1] 0.01060078
# > getProbabilityFrom3Gram("settle the incident")
# [1] 0.0003675068

# 7.I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each
# arm
# toe
# finger
# * hand

# > getProbabilityFrom3Gram("in each arm")
# [1] 0.0049919
# > getProbabilityFrom3Gram("in each toe")
# [1] 8.423292e-06
# > getProbabilityFrom3Gram("in each finger")
# [1] 2.259332e-05
# > getProbabilityFrom3Gram("in each hand")
# [1] 0.009914699

# 8. Question 8
# Every inch of you is perfect from the bottom to the
# center
# middle
# side
# * top

# > getProbabilityFrom3Gram("bottom to the center")
# [1] 0.001325999
# > getProbabilityFrom3Gram("bottom to the middle")
# [1] 0.001424222
# > getProbabilityFrom3Gram("bottom to the side")
# [1] 0.002897554
# > getProbabilityFrom3Gram("bottom to the top")
# [1] 0.00766133

# I’m thankful my childhood was filled with imagination and bruises from playing
# inside
# weekly
# * outside
# daily

# > getProbabilityFrom3Gram("bruises from playing inside")
# [1] 0.0002440651
# > getProbabilityFrom3Gram("bruises from playing weekly")
# [1] 4.657072e-05
# > getProbabilityFrom3Gram("bruises from playing outside")
# [1] 0.005936436
# > getProbabilityFrom3Gram("bruises from playing daily")
# [1] 0.0001499175

# 10. Question 10
# I like how the same people are in almost all of Adam Sandler's
# novels
# stories
# movies
# *x pictures

# > getProbabilityFrom3Gram("Adam Sandler novels")
# [1] 2.818155e-05
# > getProbabilityFrom3Gram("Adam Sandler stories")
# [1] 0.0001625645
# > getProbabilityFrom3Gram("Adam Sandler movies")
# [1] 0.0001138368
# > getProbabilityFrom3Gram("Adam Sandler pictures")
# [1] 0.0001657575