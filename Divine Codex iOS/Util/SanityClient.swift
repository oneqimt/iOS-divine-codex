//
//  SanityClient.swift
//  Divine Codex iOS
//
//  Created by Dennis Miller on 5/28/26.
//

import Foundation

/*
 NOTE:I will create a new project in Sanity, then use this pattern.
 import Sanity
 import OSLog

 // Define constants for projectId and dataset
 let sanityProjectId = "zdzzu0aw"
 let sanityDataset = "production"
 // If we want debug, use this url https://cdn.sanity.io/images/
 let sanityImageBaseURL = "https://apicdn.sanity.io/images/" // Production Base URL for images

 let logger = Logger(subsystem: "com.sacredsites.Sacred-Sites", category: "SanityClient")
 // Initialize Sanity client with improved token handling
 let sanityClient: SanityClient = {
    let token = TokenManager.shared.getToken()
     // Use CDN in production, but not in development
     #if DEBUG
     logger.info("SANITY_CLIENT: Initializing for DEBUG mode.")
         let useCdn = false // Debug, set to false to get fresh data from Sanity
     #else
     logger.info("SANITY_CLIENT: Initializing for RELEASE mode.")
         let useCdn = true // Use API CDN in production for better performance and caching
     #endif
     logger.info("SANITY_CLIENT: useCdn is set to: \(useCdn, privacy: .public)")
     
     return SanityClient(
            projectId: sanityProjectId,
            dataset: sanityDataset,
            useCdn: useCdn,
            token: token
        )
 }()


 */
