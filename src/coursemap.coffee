#<< mcb80x/interactive_svg


class mcb80x.CourseMap extends mcb80x.InteractiveSVG

    constructor: ->
        super('svg/course_map.svg')


        @courseView = true
        @moduleView = false
        @currentModule = undefined

        @currentPath = 'mcb80x'

        @courseMap = [
            identifier: 'mcb80x'
            title: 'MCB80x'
            subtitle: 'The Neurobiology of Behavior'

            # 'Modules'
            children: [
                {
                    identifier: 'Intro'
                    title: 'Introduction'
                    subtitle: ''
                    status: 'under_construction'
                },

                {
                    identifier: 'ElectricalProperties'
                    title: 'The Electrical Properties of the Neuron'
                    status: 'active'

                    # 'Lectures'
                    children: [
                        {
                            identifier: 'ElectricHistory'
                            title: 'The History of Bioelectricity'
                            status: 'active'
                        },

                        {
                            identifier: 'RestingPotential'
                            title: 'The Resting Potential'
                            status: 'active'
                        },

                        {
                            identifier: 'PassiveMembrane'
                            title: 'Passive Membrane Properties'
                            status: 'active'
                        },

                        {
                            identifier: 'ActionPotential'
                            title: 'The Action Potential'
                            status: 'active'
                        },

                        {
                            identifier: 'ActionPotentialPropagation'
                            title: 'Action Potential Propagation'
                            status: 'active'
                            target: 'http://mcb80x.org/app'
                        }

                    ]
                },

                {
                    identifier: 'NeuronalSystems'
                    title: 'Neuronal Systems'
                    status: 'under_construction'
                },

                {
                    identifier: 'OrganismsAndGroups'
                    title: 'Organisms and Groups'
                    status: 'under_construction'
                }
            ]
        ]


        console.log(@getMapPath('mcb80x'))
        console.log(@getMapPath('mcb80x.ElectricalProperties'))
        console.log(@getMapPath('mcb80x.blah'))

    show: ->
        dfrd = super()
        dfrd.then(=> @initMap())
            .then(=> @enterCourseView())

    getMapPath: (p) ->
        pathElements = p.split('.')
        cursor = @courseMap
        result = undefined

        console.log(pathElements)

        while pathElements.length > 0
            currentPathElement = pathElements.pop()
            foundMatch = false

            if not cursor?
                return undefined

            for mapElement in cursor
                if mapElement.identifier is currentPathElement
                    foundMatch = true
                    result = mapElement
                    cursor = mapElement.subElements
                    break

            if not foundMatch
                return undefined

        return result


    initMap: ->

        # read some visual info out of the SVG
        courseRoot = @getMapPath('mcb80x')

        @topTitleElement = d3.select('svg #TopTitle')

        @modules = []

        for module in courseRoot.children
            sel = 'svg #' + module.identifier + 'Group'

            module.groupElement = d3.select(sel)
            if not module.groupElement? or not module.groupElement.node()?
                console.log 'No element found for module: ' + module.identifier
                continue
            bbox = module.groupElement.node().getBBox()
            module.groupBBox = bbox
            module.groupCenter = [bbox.x + bbox.width/2.0, bbox.y + bbox.height/2.0]
            module.originalTransform = module.groupElement.attr('transform')

            module.circleElement = d3.select('svg #' + module.identifier + 'Circle')
            module.titleElement = d3.select('svg #' + module.identifier + 'Title')
            module.labelsElement = d3.select('svg #' + module.identifier + 'Labels')
            module.progressHoverElement = d3.select('svg #' + module.identifier + 'ProgressHover')

            @modules.push(module)

            # set up 'lessons' if present
            if module.children?
                for lesson in module.children

                    l_id = lesson.identifier
                    if not l_id?
                        continue

                    lesson.circleElement = d3.select('svg #' + l_id + 'Circle')
                    lesson.progressHoverElement = d3.select('svg #' + l_id + 'ProgressHover')
                    lesson.progressHoverElement.style('pointer-events', 'none')



    enterCourseView: ->

        console.log('Entering Course View')

        @topTitleElement.text('The Neurobiology of Behavior')

        d3.select('#Background').on('click', undefined)

        # if currently in module view, shrink the representation of
        # that module to its original size

        if @currentModule?
            @deselectModule(@currentModule)
            @currentModule = undefined

        # install module click handlers
        for m in @modules
            do (m) =>
                el = m.groupElement

                if m.status is 'active'
                    el.on('click', => @selectModule(m))
                el.on('mouseover', =>
                    console.log(m.identifier)
                    m.progressHoverElement.attr('display', undefined)
                    m.progressHoverElement.transition().duration(500).style('opacity', 1.0)
                )

                el.on('mouseout', =>
                    m.progressHoverElement.transition()
                        .duration(50)
                        .style('opacity', 0.0)
                        .each('end', =>
                            m.progressHoverElement.attr('display', 'none')
                        )
                )

        @courseView = true
        @moduleView = false


    selectModule: (m) ->

        console.log('Selecting module: ' + m.identifier)
        @moduleView = true
        @currentModule = m


        @topTitleElement.text(m.title)

        # Expand the SVG group representing the module
        el = m.groupElement

        # remove the click handler
        el.on('click', undefined)
        el.on('mouseover', undefined)
        el.on('mouseout', undefined)

        m.progressHoverElement.transition()
            .duration(500)
            .style('opacity', 0.0)
            .each('end', =>
                m.progressHoverElement.attr('display', 'none')
            )

        # Compute the appropriate transform
        bbox = m.groupBBox
        center = m.groupCenter
        newcenter = [640.0, 400.0]

        scale = 0.95 * 720 / bbox.height

        origTransform = el.attr('transform')
        transform = origTransform ? ''

        transform += 'translate(' + newcenter[0] + ', ' + newcenter[1] + ') '
        transform += 'scale(' + scale + ') '
        transform += 'translate(' + (-1*center[0]) + ', ' + (-1*center[1]) + ') '

        el.transition().duration(1000).attr('transform', transform)

        m.titleElement.transition().duration(1000).style('opacity', 0.0)

        m.labelsElement.attr('display', undefined)
        m.labelsElement.transition().duration(4000).style('opacity', 1.0)

        # Install click handlers on the lessons within this module

        for lesson in m.children
            do (m, lesson) =>
                if lesson.target?
                    lesson.circleElement.on('click', =>
                        window.location = lesson.target
                    )
                else
                    lesson.circleElement.on('click', =>
                        alert('Under construction')
                    )

                if lesson.circleElement?
                        do (module, lesson) =>
                            circle = lesson.circleElement
                            hover = lesson.progressHoverElement
                            circle.on('mouseover', =>
                                hover.attr('display', undefined)
                                hover.transition()
                                     .duration(500)
                                     .style('opacity', 1.0)

                            )

                            circle.on('mouseout', =>
                                hover.transition()
                                     .duration(100)
                                     .style('opacity', 0.0)
                                     .each('end', =>
                                        hover.attr('display', 'none')
                                    )
                            )


        # Fade out all of the other modules

        for module in @modules
            console.log 'Hiding module: ' + module.identifier
            if module is m
                continue
            do (module) =>
                module.groupElement
                    .transition()
                    .duration(2000)
                    .style('opacity', 0.0)
                    .each('end', =>
                        module.groupElement.attr('display', 'none')
                    )

        bg = d3.select('#Background')
        bg.transition().duration(2000).style('opacity', 0.0)
        bg.on('click', =>
            console.log('bg click')
            @enterCourseView()
        )




    deselectModule: (m) ->

        console.log('Deselecting module: ' + m.identifier)

        el = m.groupElement
        originalTransform = m.originalTransform


        el.attr('transform', originalTransform)

        # fade-in all modules
        for module in @modules
            do (module) =>
                module.groupElement.attr('display', undefined)
                module.groupElement.transition()
                    .duration(2000)
                    .style('opacity', 1.0)

        d3.select('#Background').transition()
            .duration(1000)
            .style('opacity', 1.0)

        m.labelsElement.style('opacity', 0.0).attr('display', 'none')
        m.titleElement.style('opacity', 1.0).attr('display', undefined)

        for lesson in m.children
            do (lesson) =>
                console.log 'lesson: '
                console.log lesson
                lesson.circleElement.on('mouseover', undefined)
                lesson.circleElement.on('mouseout', undefined)
                lesson.circleElement.on('click', undefined)



